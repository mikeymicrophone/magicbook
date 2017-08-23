class SectionsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @section = Section.create section_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @chapter = @table_of_content.chapter
    @section_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :section_id => @section.id
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
    
    @new_section = Section.create section_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :section_id, @new_section.id }
    @chapter = @table_of_contents.first.chapter
  end
  
  def delay
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @position = @table_of_content.ordering
    @parent = @table_of_content.parent
    @succeeding = @parent.succeeding
    @last_position = @succeeding.last_child&.ordering.to_i
    @subsequent = @table_of_content.subsequent
    @table_of_content.contained.each do |table_of_content|
      table_of_content.update_attribute :chapter_id, @succeeding.chapter_id
    end
    @table_of_content.update_attribute :ordering, @last_position.next
    
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
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @table_of_content.destroy
    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def section_params
    params.require(:section).permit(:heading, :subheading)
  end
end
