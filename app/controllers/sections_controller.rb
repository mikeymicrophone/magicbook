class SectionsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @section = Section.create section_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @chapter = @table_of_content.chapter
    @section_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :section_id => @section.id

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def append
    @section = Section.find params[:id]
    @table_of_content = TableOfContent.find params[:table_of_content_id]
  end
  
  def edit
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @section = Section.find params[:id]
  end
  
  def update
    @section_table_of_content = TableOfContent.find params[:table_of_content_id]
    @table_of_contents = @section_table_of_content.contained
    @previous_section = @section_table_of_content.section
    
    @new_section = Section.create section_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :section_id, @new_section.id }
    @chapter = @table_of_contents.first.chapter

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@section_table_of_content.book) }
    end
  end
  
  def delay
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @previous_chapter = @table_of_content.chapter
    @table_of_content.delay!
    @table_of_content.reload
    @chapter = @table_of_content.chapter

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def promote
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @previous_table_of_content = @table_of_content.promote!
    @table_of_content.reload
    @chapter = @table_of_content.chapter

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @chapter = @table_of_content.chapter
    @table_of_content.destroy
    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
  end
  
  def section_params
    params.require(:section).permit(:heading, :subheading)
  end
end
