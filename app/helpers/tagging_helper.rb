module TaggingHelper
  def tagging_for(taggable)
    chips = applied_tags_for(taggable)
    picker = tagging_disclosure_for(taggable)
    return unless chips || picker

    content_tag :div, class: "tagging", id: dom_id(taggable, :tagging_controls), data: {
      turbo: true,
      controller: "tagging-panel",
      action: "turbo:submit-start->tagging-panel#remember turbo:submit-end->tagging-panel#restore"
    } do
      safe_join([chips, picker].compact)
    end
  end
  alias tagging_panel_for tagging_for

  def tagging_picker_for(taggable)
    return unless tagging_editor?(taggable)

    content_tag :div, id: dom_id(taggable, :tagging), class: "tagging-panel" do
      safe_join([
        apply_existing_tag_to(taggable),
        create_tag_for(taggable)
      ].compact)
    end
  end

  def apply_existing_tag_to(taggable)
    return unless tagging_editor?(taggable)

    render partial: "taggings/apply_existing",
      formats: [:html],
      locals: {
        taggable: taggable,
        available_tags: tags_available_for(taggable)
      }
  end

  def create_tag_for(taggable)
    return unless tagging_editor?(taggable)

    render partial: "taggings/create",
      formats: [:html],
      locals: {
        taggable: taggable,
        tag: new_tag_for_panel,
        tag_contexts: tag_contexts_for_panel
      }
  end

  def applied_tags_for(taggable)
    taggings = taggable.taggings.includes(tag: :tag_context)
    return if taggings.none? && !tagging_editor?(taggable)

    render partial: "taggings/applied",
      formats: [:html],
      locals: {
        taggable: taggable,
        taggings: taggings,
        editable: tagging_editor?(taggable)
      }
  end

  def tagging_editor?(taggable)
    current_mage&.tagging_editor_for?(taggable)
  end

  def tagging_disclosure_for(taggable)
    picker = tagging_picker_for(taggable)
    return unless picker

    content_tag :div, class: "tagging-disclosure", data: { controller: "tagging-disclosure" } do
      safe_join([
        content_tag(
          :button,
          image_tag(asset_path("tag.svg"), alt: ""),
          type: "button",
          class: "tagging-disclosure-toggle",
          title: "Tags",
          aria: { label: "Tags", expanded: false, controls: dom_id(taggable, :tagging) },
          data: {
            action: "tagging-disclosure#toggle",
            tagging_disclosure_target: "button"
          }
        ),
        content_tag(:div, picker, class: "tagging-disclosure-panel hidden", data: { tagging_disclosure_target: "panel" })
      ])
    end
  end

  def tag_label(tag)
    tag.tag_context ? "#{tag.tag_context.name}: #{tag.name}" : tag.name
  end

  def resolved_tag_style_color(tag_context)
    return unless tag_context

    current_mage&.color_for_tag_context(tag_context) || tag_context.color.presence
  end

  def tag_style_css(tag_context)
    color = resolved_tag_style_color(tag_context)
    "--tag-color: #{color}" if color.present?
  end

  private

  def tags_available_for(taggable)
    applied_ids = taggable.tag_ids
    scope = Tag.left_joins(:tag_context).includes(:tag_context).order(Arel.sql("tag_contexts.name NULLS FIRST"), "tags.name")
    scope = scope.where(tags: { kind: "user" }) unless current_mage&.admin?
    applied_ids.any? ? scope.where.not(id: applied_ids) : scope
  end

  def tag_contexts_for_panel
    scope = TagContext.order(:name)
    current_mage&.admin? ? scope : scope.where(kind: "user")
  end

  def new_tag_for_panel
    @tag&.new_record? && @tag.errors.any? ? @tag : Tag.new
  end
end
