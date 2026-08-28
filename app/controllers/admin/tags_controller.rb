module Admin
  class TagsController < ApplicationController
    before_action :require_admin!
    before_action :set_tag_context
    before_action :set_tag, only: [:edit, :update, :destroy]

    def new
      @tag = @tag_context.tags.new
    end

    def create
      @tag = @tag_context.tags.new(tag_params.merge(kind: "user"))
      if @tag.save
        redirect_to admin_tag_contexts_path, notice: "Tag added."
      else
        load_index
        render "admin/tag_contexts/index", status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @tag.update(tag_params)
        redirect_to admin_tag_contexts_path, notice: "Tag updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @tag.destroy
        redirect_to admin_tag_contexts_path, notice: "Tag removed."
      else
        redirect_to admin_tag_contexts_path, alert: @tag.errors.full_messages.to_sentence
      end
    end

    private

    def require_admin!
      authenticate_mage!
      authorize! :manage, :all
    end

    def set_tag_context
      @tag_context = TagContext.find(params[:tag_context_id])
    end

    def set_tag
      @tag = @tag_context.tags.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :slug)
    end

    def load_index
      @tag_contexts = TagContext.includes(tags: { taggings: :taggable }).order(:name)
      @tag_context = @tag_context
      @lists = List.order(:name)
    end
  end
end
