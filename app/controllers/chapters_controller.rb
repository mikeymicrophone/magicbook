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
    @chapter = @book.table_of_contents.where(:edition_id => @edition, :section_id => nil).where.not(:chapter_id => nil).where(:ordering => free_chapter_position).first.chapter
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
    @edition = Edition.find params[:edition_id]
    @chapter = Chapter.find params[:id]
  end
  
  def chapter_params
    params.require(:chapter).permit(:title, :subtitle)
  end
end
