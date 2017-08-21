class ChaptersController < ApplicationController
  load_and_authorize_resource
  
  def create
    @chapter = Chapter.create chapter_params
    @edition = Edition.find params[:edition]
    @chapter.locate params
  end
  
  def append
    @chapter = Chapter.find params[:chapterId]
    @chapter.edition = Edition.find params[:editionId]
    @chapter.book = Book.find params[:bookId]
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
    @book = Book.find params[:book_id]
    @edition = @book.editions.last
    @chapter = Chapter.find params[:id]
    @table_of_content = @book.table_of_contents.chapterish.where(:edition => @edition, :chapter => @chapter).take
    @previous_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).where(:ordering => @table_of_content.ordering - 1).take&.chapter
    @next_chapter = @book.table_of_contents.chapterish.where(:edition => @edition).where(:ordering => @table_of_content.ordering + 1).take&.chapter
  end
  
  def promote
    @table_of_content = TableOfContent.chapterish.where(:book_id => params[:book_id], :edition_id => params[:edition_id], :chapter_id => params[:id]).first
    @previous_position = @table_of_content.ordering
    @previous_table_of_content = TableOfContent.chapterish.where(:book_id => params[:book_id], :edition_id => @table_of_content.edition_id, :ordering => @previous_position.pred).first
    @table_of_content.update_attribute :ordering, @previous_position.pred
    @previous_table_of_content.update_attribute :ordering, @previous_position
  end
  
  def chapter_params
    params.require(:chapter).permit(:title, :subtitle)
  end
end
