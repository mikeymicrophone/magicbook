module Admin
  class TagContextsController < ApplicationController
    before_action :require_admin!
    before_action :set_tag_context, only: [:edit, :update, :destroy]

    def index
      @tag_contexts = TagContext.includes(tags: { taggings: :taggable }).order(:name)
      @tag_context = TagContext.new
      @lists = List.order(:name)
    end

    def create
      @tag_context = TagContext.new(tag_context_params.merge(kind: "user"))
      if @tag_context.save
        redirect_to admin_tag_contexts_path, notice: "Tag style added."
      else
        load_index
        render :index, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @tag_context.update(tag_context_params)
        redirect_to admin_tag_contexts_path, notice: "Tag style updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @tag_context.destroy
        redirect_to admin_tag_contexts_path, notice: "Tag style removed."
      else
        redirect_to admin_tag_contexts_path, alert: @tag_context.errors.full_messages.to_sentence
      end
    end

    private

    def require_admin!
      authenticate_mage!
      authorize! :manage, :all
    end

    def set_tag_context
      @tag_context = TagContext.find(params[:id])
    end

    def tag_context_params
      params.require(:tag_context).permit(:name, :slug, :color)
    end

    def load_index
      @tag_contexts = TagContext.includes(tags: { taggings: :taggable }).order(:name)
      @lists = List.order(:name)
    end
  end
end
