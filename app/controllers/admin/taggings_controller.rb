module Admin
  class TaggingsController < ApplicationController
    include ResolvesTaggable

    before_action :authenticate_mage!

    def create
      tag = Tag.find(tagging_params.fetch(:tag_id))
      @taggable = resolved_taggable
      raise ActiveRecord::RecordNotFound unless @taggable
      authorize_tagging!(@taggable)
      raise CanCan::AccessDenied if tag.system? && !current_mage.admin?

      tagging = Tagging.find_or_initialize_by(tag: tag, taggable: @taggable)
      tagging.mage ||= current_mage

      if tagging.save
        @taggable.reload
        respond_to_tagging "#{tag.name} applied."
      else
        @tagging_alert = tagging.errors.full_messages.to_sentence
        respond_to_tagging_error
      end
    end

    def destroy
      tagging = Tagging.find(params[:id])
      @taggable = tagging.taggable
      authorize_tagging!(@taggable)
      tag_name = tagging.tag.name
      tagging.destroy!
      @taggable.reload
      respond_to_tagging "#{tag_name} removed."
    end

    private

    def tagging_params
      params.require(:tagging).permit(:tag_id, :taggable_type, :taggable_id, :list_id)
    end

    def respond_to_tagging(notice)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to html_tagging_location, notice: notice }
      end
    end

    def respond_to_tagging_error
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to html_tagging_location, alert: @tagging_alert }
      end
    end

    def html_tagging_location
      taggable_param(:taggable_type).present? ? after_tagging_path(@taggable) : admin_tag_contexts_path
    end
  end
end
