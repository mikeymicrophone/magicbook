class ChaptersController < ApplicationController
  def create
    @chapter = Chapter.create chapter_params
    @chapter.locate params
  end
  
  def chapter_params
    params.require(:chapter).permit(:title, :subtitle)
  end
end
