class ListedItemsController < ApplicationController
  def new
    @list = List.find params[:list_id]
  end
  
  def create
    @listed_item = ListedItem.new listed_item_params
    @listed_item.list_id = params[:list_id]
    @listed_item.save
  end
  
  def edit
    @listed_item = ListedItem.find params[:id]
    if @listed_item.privacy == 'published'
      @listed_item.privacy = 'unreviewed'
    elsif @listed_item.privacy == 'secret'
      @listed_item.privacy = 'unreviewed_secret'
    end
  end
  
  def update
    @listed_item = ListedItem.find params[:id]
    @listed_item.update_attributes listed_item_params
  end
  
  def review
    @listed_items = ListedItem.unreviewed
  end
  
  def approve
    @listed_item = ListedItem.find params[:id]
    case @listed_item.privacy
    when 'unreviewed'
      @listed_item.update_attribute :privacy, 'published'
    when 'unreviewed_secret'
      @listed_item.update_attribute :privacy, 'secret'
    end
    redirect_to :action => :review
  end
  
  def reject
    @listed_item = ListedItem.find params[:id]
    @listed_item.update_attribute :privacy, 'rejected'
    redirect_to :action => :review
  end
  
  def listed_item_params
    params.require(:listed_item).permit(:designation, :expression, :content_type, :content_id, :ordering, :privacy)
  end
end
