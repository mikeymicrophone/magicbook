class Tagging::SystemSeeder
  FLAGS_CONTEXT = { slug: "flags", name: "Flags", kind: "system" }.freeze
  AI_GENERATED_TAG = { slug: "ai-generated", name: "AI generated", kind: "system" }.freeze
  STARTER_CONTEXTS = [
    { slug: "format", name: "Format", kind: "user" },
    { slug: "strategy", name: "Strategy", kind: "user" },
    { slug: "power-level", name: "Power level", kind: "user" },
    { slug: "era", name: "Era", kind: "user" }
  ].freeze

  def call
    context = TagContext.find_or_initialize_by(slug: FLAGS_CONTEXT.fetch(:slug))
    context.assign_attributes(FLAGS_CONTEXT)
    context.save!

    tag = context.tags.find_or_initialize_by(slug: AI_GENERATED_TAG.fetch(:slug))
    tag.assign_attributes(AI_GENERATED_TAG)
    tag.save!

    STARTER_CONTEXTS.each do |attributes|
      TagContext.find_or_create_by!(slug: attributes.fetch(:slug)) do |starter_context|
        starter_context.assign_attributes(attributes)
      end
    end

    tag
  end
end
