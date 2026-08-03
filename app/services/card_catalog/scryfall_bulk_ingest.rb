require "json"
require "net/http"
require "tempfile"
require "zlib"

module CardCatalog
  class ScryfallBulkIngest
    BULK_DATA_URI = URI("https://api.scryfall.com/bulk-data")
    SPECIAL_FRAME_EFFECTS = %w[etched extendedart inverted showcase textless].freeze

    def initialize(importer: Importer.new, logger: Rails.logger)
      @importer = importer
      @logger = logger
    end

    # Downloads Scryfall's Default Cards JSONL file, which contains English card
    # printings. This is intentionally a bulk operation, not a per-card lookup.
    def call
      Tempfile.create(["magicbook-scryfall-default-cards", ".jsonl.gz"], binmode: true) do |file|
        download_to(default_cards_uri, file)
        file.flush
        File.open(file.path, "rb") { |input| ingest_io!(input) }
      end
    end

    # Public for tests and for an operator who has already downloaded the bulk
    # file. `input` must be the gzipped JSONL payload supplied by Scryfall.
    def ingest_io!(input)
      candidates = best_printing_per_set(input)
      preferred_keys = preferred_printing_keys(candidates)

      candidates.sort_by { |_key, candidate| [candidate[:set][:released_on].to_s, candidate[:printing][:collector_number].to_s] }
        .each do |key, candidate|
          payload = candidate.except(:style)
          @importer.import_printing!(**payload, printing: candidate[:printing].merge(preferred: preferred_keys.include?(key)))
        end

      migrated = migrate_remaining_list_cards!
      @logger.info("Migrated #{migrated} legacy list-card links to preferred printings")

      candidates.size
    end

    # Cards without a Multiverse ID still have a concept from the initial
    # backfill. Once the catalog is present, their list links can safely use the
    # concept's preferred ordinary printing.
    def migrate_remaining_list_cards!
      Card.joins(:card_inclusions).where(card_set_id: nil).includes(:card_concept).sum do |legacy_card|
        replacement = legacy_card.card_concept.preferred_printing
        next 0 unless replacement&.card_set_id && replacement.id != legacy_card.id

        CardInclusion.where(card_id: legacy_card.id).update_all(card_id: replacement.id)
      end
    end

    private

    def default_cards_uri
      bulk_data = JSON.parse(read(BULK_DATA_URI)).fetch("data")
      default_cards = bulk_data.find { |entry| entry["type"] == "default_cards" }
      raise "Scryfall did not provide Default Cards bulk data" unless default_cards

      download_uri = default_cards["jsonl_download_uri"] || default_cards.fetch("download_uri")
      URI(download_uri)
    end

    def best_printing_per_set(input)
      candidates = {}
      legacy_multiverse_ids = Hash.new { |hash, key| hash[key] = [] }

      Zlib::GzipReader.wrap(input).each_line do |line|
        source = JSON.parse(line)
        next unless eligible_printing?(source)

        candidate = candidate_from(source)
        key = [candidate[:oracle_id], candidate[:set][:code]]
        legacy_multiverse_ids[key].concat(Array(source["multiverse_ids"]))
        current = candidates[key]
        candidates[key] = candidate if current.nil? || (style_score(candidate) <=> style_score(current)) == -1
      end

      candidates.each do |key, candidate|
        candidate[:printing][:legacy_multiverse_ids] = legacy_multiverse_ids[key].uniq
      end

      candidates
    end

    def preferred_printing_keys(candidates)
      candidates.group_by { |_key, candidate| candidate[:oracle_id] }
        .transform_values { |records| records.min_by { |_key, candidate| preferred_score(candidate) }.first }
        .values
        .to_h { |key| [key, true] }
    end

    def eligible_printing?(source)
      source["object"] == "card" &&
        source["oracle_id"].present? &&
        source["lang"] == "en" &&
        source.fetch("games", []).include?("paper") &&
        !source["digital"]
    end

    def candidate_from(source)
      {
        name: source.fetch("name"),
        oracle_id: source.fetch("oracle_id"),
        oracle_text: oracle_text_from(source),
        keywords: source.fetch("keywords", []),
        faces: faces_from(source),
        set: {
          code: source.fetch("set"),
          name: source.fetch("set_name"),
          released_on: source.fetch("released_at"),
          set_type: source["set_type"]
        },
        printing: {
          scryfall_id: source.fetch("id"),
          collector_number: source["collector_number"],
          image_url: image_url_from(source),
          multiverse_id: Array(source["multiverse_ids"]).first,
          released_on: source.fetch("released_at")
        },
        style: {
          promo: source["promo"],
          variation: source["variation"],
          full_art: source["full_art"],
          frame_effects: source.fetch("frame_effects", [])
        }
      }
    end

    def faces_from(source)
      source.fetch("card_faces", [source]).map do |face|
        {
          colors: face["colors"] || source["colors"] || [],
          types: face.fetch("type_line", source.fetch("type_line", "")).split("—").first.split,
          mana_value: source["cmc"]
        }
      end
    end

    def oracle_text_from(source)
      source.fetch("card_faces", [source])
        .filter_map { |face| face["oracle_text"] }
        .join("\n//\n")
    end

    def image_url_from(source)
      source.dig("image_uris", "png") || source.dig("card_faces", 0, "image_uris", "png")
    end

    def style_score(candidate)
      style = candidate[:style]
      [
        style[:promo] ? 1 : 0,
        style[:variation] ? 1 : 0,
        style[:full_art] ? 1 : 0,
        (style[:frame_effects] & SPECIAL_FRAME_EFFECTS).any? ? 1 : 0,
        candidate[:printing][:collector_number].to_s
      ]
    end

    def preferred_score(candidate)
      style_score(candidate) + [candidate[:set][:released_on].to_s]
    end

    def read(uri)
      response_for(uri) { |response| response.body }
    end

    def download_to(uri, output)
      response_for(uri) { |response| response.read_body { |chunk| output.write(chunk) } }
    end

    def response_for(uri, redirects_remaining: 3, &block)
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json;q=0.9,*/*;q=0.8"
      request["User-Agent"] = "Magicbook card catalog importer"

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request) do |response|
          if response.is_a?(Net::HTTPRedirection)
            raise "too many redirects while downloading Scryfall data" if redirects_remaining.zero?

            return response_for(URI.join(uri, response["location"]), redirects_remaining: redirects_remaining - 1, &block)
          end

          raise "Scryfall download failed with #{response.code}" unless response.is_a?(Net::HTTPSuccess)

          return yield response
        end
      end
    end
  end
end
