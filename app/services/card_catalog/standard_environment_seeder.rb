module CardCatalog
  class StandardEnvironmentSeeder
    SOURCE = "standard-2026-08-02"

    # Current paper Standard after Marvel Super Heroes and before The Hobbit.
    STANDARD_SETS = [
      ["woe", "Wilds of Eldraine", "2023-09-08", "expansion"],
      ["lci", "The Lost Caverns of Ixalan", "2023-11-17", "expansion"],
      ["mkm", "Murders at Karlov Manor", "2024-02-09", "expansion"],
      ["otj", "Outlaws of Thunder Junction", "2024-04-19", "expansion"],
      ["big", "The Big Score", "2024-04-19", "expansion"],
      ["blb", "Bloomburrow", "2024-08-02", "expansion"],
      ["dsk", "Duskmourn: House of Horror", "2024-09-27", "expansion"],
      ["fdn", "Magic: The Gathering Foundations", "2024-11-15", "core"],
      ["dft", "Aetherdrift", "2025-02-14", "expansion"],
      ["tdm", "Tarkir: Dragonstorm", "2025-04-11", "expansion"],
      ["fin", "Magic: The Gathering—FINAL FANTASY", "2025-06-13", "expansion"],
      ["eoe", "Edge of Eternities", "2025-08-01", "expansion"],
      ["spm", "Marvel's Spider-Man", "2025-09-26", "expansion"],
      ["tla", "Avatar: The Last Airbender", "2025-11-21", "expansion"],
      ["ecl", "Lorwyn Eclipsed", "2026-01-23", "expansion"],
      ["tmt", "Teenage Mutant Ninja Turtles", "2026-03-06", "expansion"],
      ["sos", "Secrets of Strixhaven", "2026-04-24", "expansion"],
      ["msh", "Marvel Super Heroes", "2026-06-26", "expansion"]
    ].freeze
    STANDARD_SET_CODES = STANDARD_SETS.map(&:first).freeze

    FUNCTIONS = [
      { slug: "interaction", name: "Interaction", description: "Cards that disrupt an opponent's plan." },
      { slug: "removal", name: "Removal", parents: %w[interaction], description: "Cards that remove or neutralize opposing permanents." },
      { slug: "destroy", name: "Destroy", parents: %w[removal] },
      { slug: "exile", name: "Exile", parents: %w[removal] },
      { slug: "damage-removal", name: "Damage removal", parents: %w[removal] },
      { slug: "bounce", name: "Bounce", parents: %w[removal] },
      { slug: "edict", name: "Edict", parents: %w[removal] },
      { slug: "creature-combat", name: "Creature combat" },
      { slug: "fight", name: "Fight", parents: %w[damage-removal creature-combat] },
      { slug: "bite", name: "Bite", parents: %w[damage-removal creature-combat] },
      { slug: "card-advantage", name: "Card advantage" },
      { slug: "card-draw", name: "Card draw", parents: %w[card-advantage] },
      { slug: "card-selection", name: "Card selection" },
      { slug: "looting", name: "Looting and rummaging", parents: %w[card-selection] },
      { slug: "evasion", name: "Evasion" },
      { slug: "flying", name: "Flying", parents: %w[evasion] },
      { slug: "menace", name: "Menace", parents: %w[evasion] },
      { slug: "trample", name: "Trample", parents: %w[evasion] },
      { slug: "unblockable", name: "Unblockable", parents: %w[evasion] },
      { slug: "mana-acceleration", name: "Mana acceleration" },
      { slug: "land-ramp", name: "Land ramp", parents: %w[mana-acceleration] },
      { slug: "treasure", name: "Treasure", parents: %w[mana-acceleration] },
      { slug: "resilience", name: "Resilience" },
      { slug: "hexproof", name: "Hexproof", parents: %w[resilience] },
      { slug: "ward", name: "Ward", parents: %w[resilience] },
      { slug: "indestructible", name: "Indestructible", parents: %w[resilience] },
      { slug: "graveyard-value", name: "Graveyard value" },
      { slug: "recursion", name: "Recursion", parents: %w[graveyard-value] }
    ].freeze

    def initialize(set_codes: STANDARD_SET_CODES, logger: Rails.logger)
      @set_codes = set_codes.map(&:downcase)
      @logger = logger
    end

    def call
      ActiveRecord::Base.transaction do
        standard = seed_standard_format
        functions = seed_functions
        assignment_count = assign_standard_concepts(standard, functions)

        {
          format: standard,
          sets: standard.card_sets.count,
          concepts: standard.card_concepts.distinct.count,
          assignments: assignment_count
        }
      end
    end

    private

    def seed_standard_format
      format = Format.find_or_initialize_by(code: "standard")
      format.update!(
        name: "Standard",
        description: "Current paper Standard environment as of August 2, 2026."
      )

      sets = standard_sets
      format.card_sets = sets
      format
    end

    def standard_sets
      metadata_by_code = STANDARD_SETS.index_by(&:first)

      @set_codes.map do |code|
        metadata = metadata_by_code[code]
        set = CardSet.find_or_initialize_by(code: code)

        if set.new_record? && metadata
          _code, name, released_on, set_type = metadata
          set.assign_attributes(
            name: name,
            released_on: released_on,
            set_type: set_type,
            category: CardSet.category_for_set_type(set_type)
          )
          set.save!
        elsif set.new_record?
          raise ArgumentError, "No metadata exists for Standard set #{code.inspect}"
        end

        set
      end
    end

    def seed_functions
      functions = FUNCTIONS.to_h do |attributes|
        function = CardFunction.find_or_initialize_by(slug: attributes.fetch(:slug))
        function.update!(
          name: attributes.fetch(:name),
          description: attributes[:description]
        )
        [function.slug, function]
      end

      FUNCTIONS.each do |attributes|
        Array(attributes[:parents]).each do |parent_slug|
          CardFunctionRelation.find_or_create_by!(
            parent_function: functions.fetch(parent_slug),
            child_function: functions.fetch(attributes.fetch(:slug))
          )
        end
      end

      functions
    end

    def assign_standard_concepts(standard, functions)
      CardFunctionAssignment.where(source: SOURCE).delete_all

      standard.card_concepts.distinct.find_each do |concept|
        classifications_for(concept).each do |slug|
          assignment = CardFunctionAssignment.find_or_initialize_by(
            card_concept: concept,
            card_function: functions.fetch(slug)
          )
          assignment.source = SOURCE if assignment.new_record?
          assignment.save!
        end
      end

      CardFunctionAssignment.where(source: SOURCE).count
    end

    def classifications_for(concept)
      text = concept.oracle_text.to_s.downcase
      keywords = concept.keywords.map(&:downcase)
      classifications = []

      fight = text.match?(/\bfights?\b/)
      bite = text.match?(/deals? damage equal to (?:its|that creature's|this creature's) power/)

      classifications << "fight" if fight
      classifications << "bite" if bite && !fight
      classifications << "destroy" if text.match?(/\bdestroy target\b/)
      classifications << "exile" if text.match?(/\bexile target\b/)
      classifications << "damage-removal" if !fight && !bite && text.match?(/deals? .+ damage to (?:any|target) (?:target|creature|planeswalker)/)
      classifications << "bounce" if text.match?(/return target .+ to (?:its|their) owner's hand/)
      classifications << "edict" if text.match?(/(?:target|each) opponent sacrifices? (?:a|one|two) creature/)

      classifications << "card-draw" if text.match?(/\bdraw (?:(?:a|one|two|three|four|five|x|\d+) cards?|that many cards?|cards? equal to|cards? for each)\b/)
      classifications << "looting" if text.match?(/draw .+ then discard|discard .+ then draw/)

      classifications << "flying" if keywords.include?("flying")
      classifications << "menace" if keywords.include?("menace")
      classifications << "trample" if keywords.include?("trample")
      classifications << "unblockable" if text.match?(/can't be blocked|can’t be blocked/) || (keywords & %w[fear intimidate shadow horsemanship skulk]).any?

      classifications << "land-ramp" if text.match?(/search your library for (?:a|up to .+) (?:basic )?land card.+put (?:it|that card) onto the battlefield/m)
      classifications << "treasure" if text.match?(/create .+ treasure token/)
      classifications << "hexproof" if keywords.include?("hexproof")
      classifications << "ward" if keywords.include?("ward")
      classifications << "indestructible" if keywords.include?("indestructible")
      classifications << "recursion" if text.match?(/return target .+ card from (?:a|your) graveyard to (?:the battlefield|your hand)/)

      classifications.uniq
    end
  end
end
