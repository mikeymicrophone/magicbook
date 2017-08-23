class ParagraphsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @paragraph = Paragraph.create paragraph_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @section = @table_of_content.section
    @paragraph_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :paragraph_id => @paragraph.id
  end
  
  def append
    @paragraph = Paragraph.find params[:id]
    @table_of_content = TableOfContent.find params[:table_of_content_id]
  end
  
  def delay
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @position = @table_of_content.ordering
    @parent = @table_of_content.parent
    @succeeding = @parent.succeeding
    @last_position = @succeeding.last_child&.ordering.to_i
    @subsequent = @table_of_content.subsequent
    @table_of_content.update_attributes :section_id => @succeeding.section_id, :ordering => @last_position.next
    
    @subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def promote
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @previous_position = @table_of_content.ordering
    @previous_table_of_content = @table_of_content.previous
    @table_of_content.update_attribute :ordering, @previous_position.pred
    @previous_table_of_content.update_attribute :ordering, @previous_position
  end
  
  def edit
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @paragraph = Paragraph.find params[:id]
  end
  
  def update
    @paragraph_table_of_content = TableOfContent.find(params[:table_of_content_id])
    @table_of_contents = @paragraph_table_of_content.contained
    
    @new_paragraph = Paragraph.create paragraph_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :paragraph_id, @new_paragraph.id }
    @section = @table_of_contents.first.section
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @position = @table_of_content.ordering
    @table_of_content.destroy

    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def paragraph_params
    params.require(:paragraph).permit(:text, :book_id, :edition_id, :chapter_id, :section_id)
  end
end
