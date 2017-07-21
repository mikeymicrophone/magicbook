class ListsController < ApplicationController
  load_and_authorize_resource
  
  def new
    @list = List.new
  end
  
  def create
    @list = List.new list_params
    @list.magician = current_magician
    @list.save
    redirect_to @list
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
  end
  
  def edit
    @list = List.find params[:id]
  end
  
  def update
    @list = List.find params[:id]
    @list.update_attributes list_params
    redirect_to @list
  end
  
  def index
    @lists = if current_magician
      List.visible
    elsif current_muggle
      List.visible + List.visible_to(current_muggle)
    else
      List.published
    end
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
    params.require(:list).permit :name, :mode, :privacy
  end
end
