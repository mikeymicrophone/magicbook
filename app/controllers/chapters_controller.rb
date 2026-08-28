class ChaptersController < ApplicationController
  load_and_authorize_resource
  
  def create
    @chapter = Chapter.create chapter_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @edition = @table_of_content.edition
    @chapter_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :chapter_id => @chapter.id

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def append
    @chapter = Chapter.find params[:id]
    @table_of_content = TableOfContent.find params[:table_of_content_id]
  end
  
  def free
    @book = Book.find params[:book_id]
    @edition = @book.current_edition
    @table_of_contents = @book.table_of_contents.chapterish.where(edition: @edition).ordered.to_a
    raise ActiveRecord::RecordNotFound, 'The current edition has no chapters.' if @table_of_contents.empty?

    today = Date.today
    dividend = today.year + today.month + today.day
    @table_of_content = @table_of_contents.fetch(dividend % @table_of_contents.length)
    @chapter = @table_of_content.chapter
    chapter_index = @table_of_contents.index(@table_of_content)
    @previous_chapter = @table_of_contents[chapter_index - 1]&.chapter if chapter_index.positive?
    @next_chapter = @table_of_contents[chapter_index + 1]&.chapter
  end
  
  def next
    @book = Book.find params[:book_id]
    @edition = Edition.find params[:edition_id]
    @chapter = Chapter.find params[:id]
  end
  
  def show
    @book = Book.find params[:book_id]
    @edition = Edition.find params[:edition_id]
    @chapter = Chapter.find params[:id]
    @table_of_content = @book.table_of_contents.chapterish.where(:edition => @edition, :chapter => @chapter).take
    @previous_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).where(:ordering => @table_of_content.ordering - 1).take&.chapter
    @next_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).where(:ordering => @table_of_content.ordering + 1).take&.chapter
  end
  
  def edit
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @chapter = Chapter.find params[:id]
  end
  
  def update
    @chapter_table_of_content = TableOfContent.find params[:table_of_content_id]
    @table_of_contents = @chapter_table_of_content.contained
    @previous_chapter = @chapter_table_of_content.chapter
    
    @new_chapter = Chapter.create chapter_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :chapter_id, @new_chapter.id }
    @edition = @table_of_contents.first.edition

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@chapter_table_of_content.book) }
    end
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @edition = @table_of_content.edition
    @table_of_content.destroy
    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def edit_as
    @book = Book.find params[:book_id]
    @edition = @book.editions.last
    @chapter = Chapter.find params[:id]
    @table_of_content = @book.table_of_contents.chapterish.where(:edition => @edition, :chapter => @chapter).take
    @previous_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).where(:ordering => @table_of_content.ordering - 1).take&.chapter
    @next_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).where(:ordering => @table_of_content.ordering + 1).take&.chapter
  end
  
  def promote
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @previous_table_of_content = @table_of_content.promote!
    @table_of_content.reload
    @edition = @table_of_content.edition

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def chapter_params
    params.require(:chapter).permit(:title, :subtitle)
  end
end
