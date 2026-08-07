module SectionsHelper
  def section_form table_of_content, section = Section.new
    frame_id = section.persisted? ? dom_id(section) : dom_id(table_of_content, :append_section_form)

    turbo_frame_tag frame_id, data: { controller: 'toc-editor' } do
      form_with model: section, local: true, class: 'section_form', data: { turbo_stream: true } do |section_form|
        safe_join([
          section_form.text_field(:heading, placeholder: 'Section heading', class: 'section_heading', data: { toc_editor_target: 'input' }),
          tag.br,
          section_form.text_area(:subheading, placeholder: 'Section subheading', class: 'section_subheading'),
          section_form.submit(section.persisted? ? 'Save' : 'Append'),
          hidden_field_tag(:table_of_content_id, table_of_content.id)
        ])
      end
    end
  end
  
  def section_control section_table_of_content
    section = section_table_of_content.section
    safe_join([
      tag.header(:class => 'section_heading') do
        section.heading
      end +
      tag.header(:class => 'section_subheading') do
          section.subheading
        end
    ])
  end
  
  def edit_controls_for_section section_table_of_content
    section = section_table_of_content.section
    div_for(section, :controls_for, :class => 'controls') do
      if section_table_of_content.parent.succeeding.present?
        link_to('delay', delay_section_path(section, :table_of_content_id => section_table_of_content), title: 'move to next chapter', data: { turbo_method: :put, turbo_stream: true })
      end.to_s.html_safe +
      if section_table_of_content.previous.present?
        link_to('promote', promote_section_path(section, :table_of_content_id => section_table_of_content), title: "put before previous section (at #{section_table_of_content.ordering})", data: { turbo_method: :put, turbo_stream: true })
      end.to_s.html_safe +
      link_to('edit', edit_section_path(section, :table_of_content_id => section_table_of_content), data: { action: 'click->toc-editor#open', turbo_frame: dom_id(section) }) +
      link_to('remove', section_path(section, :table_of_content_id => section_table_of_content), data: { turbo_method: :delete, turbo_stream: true })
    end
  end
end
