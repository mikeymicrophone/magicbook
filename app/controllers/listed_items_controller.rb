class ListedItemsController < ApplicationController
  def new
    @list = List.find params[:list_id]
  end
  
  def create
    @listed_item = ListedItem.new listed_item_params
    @listed_item.list_id = params[:list_id]
    @listed_item.save
  end
  
  def listed_item_params
    params.require(:listed_item).permit(:designation, :expression, :content_type, :content_id, :ordering)
  end
end
