module Admin
  class TaggingsController < ApplicationController
    before_action :require_admin!

    def create
      tag = Tag.find(tagging_params.fetch(:tag_id))
      list = List.find(tagging_params.fetch(:list_id))
      tagging = Tagging.find_or_initialize_by(tag: tag, taggable: list)
      tagging.mage ||= current_mage

      if tagging.save
        redirect_to admin_tag_contexts_path, notice: "#{tag.name} applied to #{list.name}."
      else
        redirect_to admin_tag_contexts_path, alert: tagging.errors.full_messages.to_sentence
      end
    end

    def destroy
      tagging = Tagging.find(params[:id])
      unless tagging.taggable_type == "List"
        raise ActiveRecord::RecordNotFound
      end

      list_name = tagging.taggable.name
      tag_name = tagging.tag.name
      tagging.destroy!
      redirect_to admin_tag_contexts_path, notice: "#{tag_name} removed from #{list_name}."
    end

    private

    def require_admin!
      authenticate_mage!
      authorize! :manage, :all
    end

    def tagging_params
      params.require(:tagging).permit(:tag_id, :list_id)
    end
  end
end
