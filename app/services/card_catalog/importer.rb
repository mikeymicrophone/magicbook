module CardCatalog
  class Importer
    COLOR_FLAGS = {
      "W" => :white,
      "U" => :blue,
      "B" => :black,
      "R" => :red,
      "G" => :green
    }.freeze

    TYPE_FLAGS = {
      "Artifact" => :artifact,
      "Creature" => :creature,
      "Enchantment" => :enchantment,
      "Instant" => :instant,
      "Land" => :land,
      "Planeswalker" => :planeswalker,
      "Sorcery" => :sorcery,
      "Tribal" => :tribal
    }.freeze

    # `faces` is the array of atomic face records for one game card. Aggregating
    # the faces is essential: Fire // Ice, for example, is both red and blue.
    def import_printing!(name:, oracle_id:, faces:, set:, printing:)
      Card.transaction do
        card_concept = find_or_initialize_concept(name, oracle_id)
        card_concept.save!

        card_set = CardSet.find_or_initialize_by(code: fetch(set, :code))
        card_set.assign_attributes(
          name: fetch(set, :name),
          released_on: fetch(set, :released_on),
          set_type: fetch(set, :set_type),
          category: CardSet.category_for_set_type(fetch(set, :set_type))
        )
        card_set.save!

        card = find_or_initialize_printing(card_concept, card_set, printing)
        card.assign_attributes(
          card_concept: card_concept,
          card_set: card_set,
          name: name,
          scryfall_id: fetch(printing, :scryfall_id),
          collector_number: fetch(printing, :collector_number),
          image_url: fetch(printing, :image_url),
          multiverse_id: fetch(printing, :multiverse_id) || card.multiverse_id,
          released_on: fetch(printing, :released_on) || card_set.released_on
        )
        apply_face_attributes(card, faces)
        card.save!

        make_preferred!(card) if fetch(printing, :preferred)
        card
      end
    end

    private

    def find_or_initialize_concept(name, oracle_id)
      if oracle_id.present?
        (CardConcept.find_by(oracle_id: oracle_id) || CardConcept.find_or_initialize_by(name: name)).tap do |concept|
          concept.oracle_id = oracle_id
          concept.name = name
        end
      else
        CardConcept.find_or_initialize_by(name: name)
      end
    end

    def apply_face_attributes(card, faces)
      face_data = Array(faces)
      colors = face_data.flat_map { |face| Array(fetch(face, :colors)) }.uniq
      types = face_data.flat_map { |face| Array(fetch(face, :types)) }.uniq

      card.colors = 0
      colors.each { |color| card.public_send("#{COLOR_FLAGS.fetch(color)}=", true) if COLOR_FLAGS.key?(color) }

      card.types = 0
      types.each { |type| card.public_send("#{TYPE_FLAGS.fetch(type)}=", true) if TYPE_FLAGS.key?(type) }

      card.converted_mana_cost = face_data.filter_map { |face| fetch(face, :mana_value) }.first
    end

    def make_preferred!(card)
      Card.where(card_concept: card.card_concept).where.not(id: card.id).update_all(preferred: false)
      card.update!(preferred: true)
    end

    # Existing list entries reference legacy Card rows. When a source printing
    # supplies one of those rows' Multiverse IDs, reuse that row so its primary
    # key — and therefore every card_inclusion — remains unchanged.
    def find_or_initialize_printing(card_concept, card_set, printing)
      Card.find_by(card_concept: card_concept, card_set: card_set) ||
        Card.where(card_set_id: nil)
          .where(multiverse_id: Array(fetch(printing, :legacy_multiverse_ids)))
          .first ||
        Card.new(card_concept: card_concept, card_set: card_set)
    end

    def fetch(hash, key)
      hash[key] || hash[key.to_s]
    end
  end
end
