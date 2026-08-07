module CitationsHelper
  def citation_form(table_of_content, citation = Citation.new, frame_id: nil)
    frame_id ||= citation.persisted? ? dom_id(citation) : dom_id(table_of_content, :append_citation_form)

    turbo_frame_tag frame_id, data: { controller: 'toc-editor' } do
      form_with model: citation, local: true, data: { turbo_stream: true } do |citation_form|
        safe_join([
          citation_form.text_area(:finding, placeholder: 'finding', data: { toc_editor_target: 'input' }),
          tag.br,
          citation_form.text_field(:source, placeholder: 'source'),
          citation_form.submit(citation.persisted? ? 'Save' : 'Append'),
          hidden_field_tag(:table_of_content_id, table_of_content.id)
        ])
      end
    end
  end
  
  def citation_control(citation_table_of_content)
    citation = citation_table_of_content.citation

    turbo_frame_tag dom_id(citation), data: { controller: 'toc-editor' } do
      content_tag(:div, class: 'div_with_data citation', data: { citation_id: citation.id }) do
        safe_join([
          div_for(citation, :finding_of) { citation.finding },
          link_to('hide', '#', class: 'citation_hider', data: { action: 'click->toc-editor#hide' }),
          div_for(citation, :source_of) { citation.source },
          edit_controls_for_citation(citation_table_of_content)
        ])
      end
    end
  end

  def citation_append_control(paragraph_table_of_content)
    frame_id = dom_id(paragraph_table_of_content, :append_citation_form)

    turbo_frame_tag frame_id do
      link_to append_paragraph_path(paragraph_table_of_content.paragraph, table_of_content_id: paragraph_table_of_content.id), title: 'Add citation', aria: { label: 'Add citation' }, data: { turbo_frame: frame_id } do
        div_for paragraph_table_of_content, :focus_tool_for, class: :new_focus_tool do
          image_tag asset_path('write.svg'), title: 'Add citation'
        end
      end
    end
  end
  
  def edit_controls_for_citation citation_table_of_content
    citation = citation_table_of_content.citation
    paragraph_table_of_content = citation_table_of_content.parent
    div_for(citation, :controls_for, :class => 'controls editor_controls citation_controls') do
      if paragraph_table_of_content.succeeding.present?
        link_to('↓', delay_citation_path(citation, table_of_content_id: citation_table_of_content), class: 'editor_icon_link', title: 'Move to next paragraph', aria: { label: 'Move to next paragraph' }, data: { turbo_method: :put, turbo_stream: true })
      end.to_s.html_safe +
      if citation_table_of_content.previous.present?
        link_to('↑', promote_citation_path(citation, table_of_content_id: citation_table_of_content), class: 'editor_icon_link', title: 'Move citation up', aria: { label: 'Move citation up' }, data: { turbo_method: :put, turbo_stream: true })
      end.to_s.html_safe +
      link_to('✎', edit_citation_path(citation, :table_of_content_id => citation_table_of_content), class: 'editor_icon_link', title: 'Edit citation', aria: { label: 'Edit citation' }, data: { action: 'click->toc-editor#open', turbo_frame: dom_id(citation) }) +
      link_to('×', citation_path(citation, :table_of_content_id => citation_table_of_content), class: 'editor_icon_link editor_remove_link', title: 'Remove citation', aria: { label: 'Remove citation' }, data: { turbo_method: :delete, turbo_stream: true })
    end
  end
end
