class ProfilesController < ApplicationController
  before_action :authenticate_mage!

  def show
    load_tag_contexts
  end

  def update
    current_mage.sync_tag_context_color_overrides!(style_color_params)
    redirect_to profile_path, notice: "Tag style colors saved."
  rescue ActiveRecord::RecordInvalid => error
    flash.now[:alert] = error.record.errors.full_messages.to_sentence
    load_tag_contexts
    render :show, status: :unprocessable_entity
  end

  private

  def load_tag_contexts
    @tag_contexts = TagContext.order(:name)
  end

  def style_color_params
    raw = params[:style_colors]
    return {} unless raw.respond_to?(:to_unsafe_h)

    allowed = TagContext.pluck(:id).map(&:to_s)
    raw.to_unsafe_h.stringify_keys.slice(*allowed)
  end
end
