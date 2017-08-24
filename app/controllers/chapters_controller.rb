class ChaptersController < ApplicationController
  load_and_authorize_resource
  
  def create
    @chapter = Chapter.create chapter_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @edition = @table_of_content.edition
    @chapter_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :chapter_id => @chapter.id
  end
  
  def append
    @chapter = Chapter.find params[:id]
    @table_of_content = TableOfContent.find params[:table_of_content_id]
  end
  
  def free
    @book = Book.find params[:book_id]
    @edition = @book.current_edition
    @chapters = @book.current_edition.chapters
    
    today = Date.today
    dividend = today.year + today.month + today.day
    divisor = @chapters.count
    free_chapter_position = dividend % divisor
    @chapter = @book.table_of_contents.chapterish.find_by(:ordering => free_chapter_position).chapter
    @table_of_content = @book.table_of_contents.chapterish.find_by(:edition => @edition, :chapter => @chapter)
    @previous_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).find_by(:ordering => @table_of_content.ordering - 1)&.chapter
    @next_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).find_by(:ordering => @table_of_content.ordering + 1)&.chapter
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
    
    @new_chapter = Chapter.create chapter_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :chapter_id, @new_chapter.id }
    @edition = @table_of_contents.first.edition
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @table_of_content.destroy
    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
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
    @previous_position = @table_of_content.ordering
    @previous_table_of_content = @table_of_content.previous
    @table_of_content.update_attribute :ordering, @previous_position.pred
    @previous_table_of_content.update_attribute :ordering, @previous_position
  end
  
  def chapter_params
    params.require(:chapter).permit(:title, :subtitle)
  end
end
