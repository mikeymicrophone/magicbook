class CitationsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @citation = Citation.create citation_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @paragraph = @table_of_content.paragraph
    @citation_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :citation_id => @citation.id

    respond_to do |format|
      format.turbo_stream
      format.js
      format.html { redirect_back fallback_location: edit_book_path(@table_of_content.book) }
    end
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
    @citation = Citation.find params[:id]
  end
  
  def update
    @citation_table_of_content = TableOfContent.find params[:table_of_content_id]
    @table_of_contents = @citation_table_of_content.contained
    @previous_citation = @citation
    
    @new_citation = Citation.create citation_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :citation_id, @new_citation.id }
    @paragraph = @table_of_contents.first.paragraph

    respond_to do |format|
      format.turbo_stream
      format.js
      format.html { redirect_back fallback_location: edit_book_path(@citation_table_of_content.book) }
    end
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @removed_citation = @table_of_content.citation
    @position = @table_of_content.ordering
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
  
  def citation_params
    params.require(:citation).permit(:source, :finding)
  end
end
