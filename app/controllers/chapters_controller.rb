class ChaptersController < ApplicationController
  def create
    @chapter = Chapter.create chapter_params
    @chapter.locate params
  end
  
  def append
    @chapter = Chapter.find params[:chapterId]
    @chapter.edition = Edition.find params[:editionId]
    @chapter.book = Book.find params[:bookId]
  end
  
  def chapter_params
    params.require(:chapter).permit(:title, :subtitle)
  end
end
