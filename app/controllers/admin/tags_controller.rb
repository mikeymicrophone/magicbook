module Admin
  class TagsController < ApplicationController
    include ResolvesTaggable

    before_action :require_admin!, except: [:create]
    before_action :authenticate_mage!, only: [:create]
    before_action :set_tag_context, except: [:create]
    before_action :set_tag_context_for_create, only: [:create]
    before_action :set_tag, only: [:edit, :update, :destroy]

    def new
      @tag = @tag_context.tags.new
    end

    def create
      @taggable = resolved_taggable
      if @taggable
        authorize_tagging!(@taggable)
      else
        authorize! :manage, :all
      end
      raise CanCan::AccessDenied if @tag_context&.system? && !current_mage.admin?
      slug = tag_params[:slug].presence || tag_params[:name].to_s.parameterize
      @tag = if @tag_context
        @tag_context.tags.find_or_initialize_by(slug: slug)
      else
        Tag.where(tag_context_id: nil).find_or_initialize_by(slug: slug)
      end

      if @tag.new_record?
        @tag.assign_attributes(name: tag_params[:name], kind: "user")
        unless @tag.save
          return respond_to_create_failure
        end
      end

      if @taggable
        tagging = Tagging.find_or_initialize_by(tag: @tag, taggable: @taggable)
        tagging.mage ||= current_mage
        tagging.save!
        @taggable.reload
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to after_tagging_path(@taggable), notice: "#{@tag.name} applied." }
        end
      else
        redirect_to admin_tag_contexts_path, notice: "Tag added."
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

    def set_tag_context_for_create
      return if params[:tag_context_id].blank?

      @tag_context = TagContext.find(params[:tag_context_id])
    end

    def set_tag
      @tag = @tag_context.tags.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :slug)
    end

    def respond_to_create_failure
      if @taggable
        respond_to do |format|
          format.turbo_stream { render :create, status: :unprocessable_entity }
          format.html { redirect_to after_tagging_path(@taggable), alert: @tag.errors.full_messages.to_sentence }
        end
      else
        load_index
        render "admin/tag_contexts/index", status: :unprocessable_entity
      end
    end

    def load_index
      @tag_contexts = TagContext.includes(tags: { taggings: :taggable }).order(:name)
      @lists = List.order(:name)
    end
  end
end
