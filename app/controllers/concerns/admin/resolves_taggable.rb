module Admin
  module ResolvesTaggable
    extend ActiveSupport::Concern

    TAGGABLE_TYPES = {
      "List" => List,
      "ListedItem" => ListedItem,
      "Book" => Book,
      "Chapter" => Chapter,
      "Edition" => Edition
    }.freeze

    private

    def resolved_taggable
      type_name = taggable_param(:taggable_type)
      id = taggable_param(:taggable_id)
      return List.find(taggable_param(:list_id)) if type_name.blank? && taggable_param(:list_id).present?
      return if type_name.blank? || id.blank?

      TAGGABLE_TYPES.fetch(type_name) { raise ActiveRecord::RecordNotFound }.find(id)
    end

    def taggable_param(key)
      params.dig(:tagging, key).presence || params[key].presence
    end

    def authorize_tagging!(taggable)
      raise CanCan::AccessDenied unless current_mage&.tagging_editor_for?(taggable)
    end

    def after_tagging_path(taggable)
      case taggable
      when List then list_path(taggable, anchor: dom_id(taggable, :tagging))
      when ListedItem then list_path(taggable.list, anchor: dom_id(taggable))
      when Book then book_path(taggable, anchor: dom_id(taggable, :tagging))
      when Chapter then chapter_path(taggable, anchor: dom_id(taggable, :tagging))
      when Edition then edition_path(taggable)
      else admin_tag_contexts_path
      end
    end
  end
end
