class ParagraphsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @paragraph = Paragraph.create paragraph_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @section = @table_of_content.section
    @paragraph_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :paragraph_id => @paragraph.id

    respond_to do |format|
      format.turbo_stream
      format.js
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def append
    @paragraph = Paragraph.find params[:id]
    @table_of_content = TableOfContent.find params[:table_of_content_id]
  end
  
  def delay
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @table_of_content.delay!
    @table_of_content.reload
  end
  
  def promote
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @previous_table_of_content = @table_of_content.promote!
    @table_of_content.reload
  end
  
  def edit
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @paragraph = Paragraph.find params[:id]
  end
  
  def update
    @paragraph_table_of_content = TableOfContent.find(params[:table_of_content_id])
    @table_of_contents = @paragraph_table_of_content.contained
    @previous_paragraph = @paragraph
    
    @new_paragraph = Paragraph.create paragraph_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :paragraph_id, @new_paragraph.id }
    @section = @table_of_contents.first.section

    respond_to do |format|
      format.turbo_stream
      format.js
      format.html { redirect_back fallback_location: edit_book_path(@paragraph_table_of_content.book) }
    end
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @removed_paragraph = @table_of_content.paragraph
    @table_of_content.destroy

    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end

    respond_to do |format|
      format.turbo_stream
      format.js
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def paragraph_params
    params.require(:paragraph).permit(:text, :book_id, :edition_id, :chapter_id, :section_id)
  end
end
