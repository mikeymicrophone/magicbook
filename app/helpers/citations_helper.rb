module CitationsHelper
  def citation_form table_of_content, citation = Citation.new
    form_with :model => citation, :id => dom_id(table_of_content.paragraph, :append_citation_to) do |citation_form|
      citation_form.text_area(:finding, :placeholder => 'finding') +
      tag.br +
      citation_form.text_field(:source, :placeholder => 'source') +
      citation_form.submit(:Append) +
      hidden_field_tag(:table_of_content_id, nil, :value => table_of_content.id)
    end
  end
  
  def citation_control citation_table_of_content
    citation = citation_table_of_content.citation
    div_with_data_for citation do
      div_for(citation, :finding_of) do
        citation.finding
      end +
      link_to('hide', "javascript: $('##{dom_id(citation)}').hide()", :class => 'citation_hider') +
      div_for(citation, :source_of) do
        citation.source
      end +
      edit_controls_for_citation(citation_table_of_content)
    end
  end
  
  def edit_controls_for_citation citation_table_of_content
    citation = citation_table_of_content.citation
    paragraph_table_of_content = citation_table_of_content.parent
    div_for(citation, :controls_for, :class => 'controls') do
      if paragraph_table_of_content.succeeding.present?
        link_to('delay', delay_citation_path(citation, :table_of_content_id => citation_table_of_content), :method => :put, :remote => true, :title => 'move to next paragraph')
      end.to_s.html_safe +
      if citation_table_of_content.previous.present?
        link_to('promote', promote_citation_path(citation, :table_of_content_id => citation_table_of_content), :method => :put, :remote => true, :title => "put before previous citation (at #{citation_table_of_content.ordering})")
      end.to_s.html_safe +
      link_to('edit', edit_citation_path(citation, :table_of_content_id => citation_table_of_content), :remote => true) +
      link_to('remove', citation_path(citation, :table_of_content_id => citation_table_of_content), :method => :delete, :remote => true)
    end
  end
end
