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
  
  def move_up
    @listed_item = ListedItem.find params[:id]
    @previous_item = @listed_item.list.listed_items.where(:ordering => @listed_item.ordering - 1).first
    if @previous_item
      position = @listed_item.ordering
      @listed_item.update_attribute :ordering, @previous_item.ordering
      @previous_item.update_attribute :ordering, position
    end
  end
  
  def move_down
    @listed_item = ListedItem.find params[:id]
    @next_item = @listed_item.list.listed_items.where(:ordering => @listed_item.ordering + 1).first
    if @next_item
      position = @listed_item.ordering
      @listed_item.update_attribute :ordering, @next_item.ordering
      @next_item.update_attribute :ordering, position
    end
  end
  
  def paragraphs_for
    @books = Book.all
    @editions = @books.map &:current_edition
    @paragraphs = @editions.compact.map(&:paragraphs).flatten.sort_by &:text
  end
  
  def listed_item_params
    params.require(:listed_item).permit(:designation, :expression, :content_type, :content_id, :ordering, :privacy)
  end
end
