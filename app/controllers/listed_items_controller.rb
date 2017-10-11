class ListedItemsController < ApplicationController
  load_and_authorize_resource :except => :create
  
  def new
    @list = List.find params[:list_id]
  end
  
  def create
    @listed_item = ListedItem.new listed_item_params
    @listed_item.list_id = params[:list_id]
    if current_scribe
      if @listed_item.privacy == 'unreviewed'
        @listed_item.privacy = 'published'
      elsif @listed_item.privacy == 'unreviewed_secret'
        @listed_item.privacy = 'secret'
      end
    end
    @listed_item.save if can? :create, @listed_item
    ListMailer.suggested(@listed_item.id).deliver if @listed_item.privacy == 'suggested' && @listed_item.list.suggestability == 'notify'
  end
  
  def edit
    @listed_item = ListedItem.find params[:id]
    if @listed_item.privacy == 'published'
      @listed_item.privacy = 'unreviewed'
    elsif @listed_item.privacy == 'secret'
      @listed_item.privacy = 'unreviewed_secret'
    end
  end
  
  def suggest_revision
    @existing_listed_item = ListedItem.find params[:id]
    
    @listed_item = ListedItem.new @existing_listed_item.attributes.slice('designation', 'expression', 'list_id', 'content_type', 'content_id').merge('replacing' => @existing_listed_item.id)
    
    respond_to do |format|
      format.html { render :body => nil }
      format.js { render :template => 'listed_items/edit.js.erb' }
    end
  end
  
  def update
    @listed_item = ListedItem.find params[:id]
    if current_scribe
      @listed_item.attributes = listed_item_params
      if @listed_item.privacy == 'unreviewed'
        @listed_item.privacy = 'published'
      elsif @listed_item.privacy == 'unreviewed_secret'
        @listed_item.privacy = 'secret'
      end
      @listed_item.save
    else
      @listed_item.update_attributes listed_item_params
    end
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
  end
  
  def reject
    @listed_item = ListedItem.find params[:id]
    @listed_item.update_attribute :privacy, 'rejected'
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
    params.require(:listed_item).permit(:designation, :expression, :content_type, :content_id, :ordering, :privacy, :replacing)
  end
end
