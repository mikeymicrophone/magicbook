class CitationsController < ApplicationController
  load_and_authorize_resource
  
  def create
    @citation = Citation.create citation_params
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @paragraph = @table_of_content.paragraph
    @citation_table_of_content = TableOfContent.create @table_of_content.content_attributes.merge :citation_id => @citation.id
  end
  
  def delay
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @position = @table_of_content.ordering
    @parent = @table_of_content.parent
    @succeeding = @parent.succeeding
    @last_position = @succeeding.last_child&.ordering.to_i
    @subsequent = @table_of_content.subsequent
    @table_of_content.update :paragraph_id => @succeeding.paragraph_id, :ordering => @last_position.next
    
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
    @citation = Citation.find params[:id]
  end
  
  def update
    @citation_table_of_content = TableOfContent.find params[:table_of_content_id]
    @table_of_contents = @citation_table_of_content.contained
    
    @new_citation = Citation.create citation_params
    @table_of_contents.each { |table_of_content| table_of_content.update_attribute :citation_id, @new_citation.id }
    @paragraph = @table_of_contents.first.paragraph
  end
  
  def destroy
    @table_of_content = TableOfContent.find params[:table_of_content_id]
    @position = @table_of_content.ordering
    @table_of_content.destroy

    @table_of_content.subsequent.each do |table_of_content|
      table_of_content.update_attribute :ordering, table_of_content.ordering.pred
    end
  end
  
  def citation_params
    params.require(:citation).permit(:source, :finding)
  end
end
