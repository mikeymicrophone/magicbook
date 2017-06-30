class ParagraphsController < ApplicationController
  def create
    @paragraph = Paragraph.new paragraph_params
    @paragraph.add_to_book paragraph_params
  end
  
  def paragraph_params
    params.require(:paragraph).permit(:text, :book_id, :edition_id, :chapter_id, :section_id)
  end
end
