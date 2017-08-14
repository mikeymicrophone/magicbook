class ListsController < ApplicationController
  load_and_authorize_resource
  
  def new
    @list = List.new
  end
  
  def create
    @list = List.new list_params
    @list.magician = current_magician
    if @list.save
      redirect_to @list
    else
      if @list.errors[:name].present?
        render 'name_was_taken.js.erb'
      end
    end
  end
  
  def show
    @list = List.find params[:id]
    @listed_items = if current_magician
      @list.ordered_items
    elsif current_muggle
      @list.items_for current_muggle
    else
      @list.published_items
    end
    if params[:sort] == 'alpha'
      @listed_items = @listed_items.sort_by { |listed_item| Rails::Html::FullSanitizer.new.sanitize listed_item.designation }
    end
    @html_title = @list.name
  end
  
  def edit
    @list = List.find params[:id]
  end
  
  def update
    @list = List.find params[:id]
    if @list.update_attributes list_params
      redirect_to @list
    else
      if @list.errors[:name].present?
        render 'name_was_taken.js.erb'
      end
    end
  end
  
  def index
    if params[:sort] == 'alpha'
      sorting_scope = :alphabetical
    elsif params[:sort] == 'recent'
      sorting_scope = :recent
    else
      sorting_scope = :randomized
    end
    @examplary = List.examplary.send(sorting_scope)
    @prominent = List.prominent.send(sorting_scope)
    @suggestion_seeking = List.suggestion_seeking.send(sorting_scope)
    @deferred = List.deferred.send(sorting_scope)
    @lists = if current_magician
      List.send(sorting_scope).visible + List.send(sorting_scope).visible_to(current_magician) + current_magician.lists.in_draft
    elsif current_muggle
      List.send(sorting_scope).visible + List.send(sorting_scope).visible_to(current_muggle.magician)
    else
      List.send(sorting_scope).published
    end
    @lists = @lists - (@examplary + @prominent + @suggestion_seeking + @deferred)
    @lists = Kaminari.paginate_array(@lists).page(params[:page]).per(27)
  end
  
  def review
    @lists = List.unreviewed
  end
  
  def approve
    @list = List.find params[:id]
    case @list.privacy
    when 'unreviewed'
      @list.update_attribute :privacy, 'published'
    when 'unreviewed_secret'
      @list.update_attribute :privacy, 'secret'
    end
    redirect_to :action => :review
  end
  
  def reject
    @list = List.find params[:id]
    @list.update_attribute :privacy, 'rejected'
    redirect_to :action => :review
  end
  
  def list_params
    params.require(:list).permit :name, :description, :mode, :privacy, :suggestability, :pin
  end
end
