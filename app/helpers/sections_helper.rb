module SectionsHelper
  def section_form table_of_content, section = Section.new
    form_with :model => section, :id => dom_id(table_of_content.chapter, :append_section_to) do |section_form|
      section_form.text_field(:heading, :placeholder => 'Section heading') +
      tag.br +
      section_form.text_area(:subheading, :placeholder => 'Section subheading') +
      section_form.submit(:Append) +
      hidden_field_tag(:table_of_content_id, nil, :value => table_of_content.id)
    end
  end
  
  def section_control section_table_of_content
    section = section_table_of_content.section
    div_with_data_for section do
      tag.header(:class => 'section_heading') do
        section.heading
      end +
      tag.header(:class => 'section_subheading') do
        section.subheading
      end
    end
  end
  
  def edit_controls_for_section section_table_of_content
    section = section_table_of_content.section
    chapter_table_of_content = section_table_of_content.parent
    div_for(section, :controls_for, :class => 'controls') do
      if chapter_table_of_content.succeeding.present?
        link_to('delay', delay_section_path(section, :table_of_content_id => section_table_of_content), :method => :put, :remote => true, :title => 'move to next chapter')
      end.to_s.html_safe +
      if section_table_of_content.previous.present?
        link_to('promote', promote_section_path(section, :table_of_content_id => section_table_of_content), :method => :put, :remote => true, :title => "put before previous section (at #{section_table_of_content.ordering})")
      end.to_s.html_safe +
      link_to('edit', edit_section_path(section, :table_of_content_id => section_table_of_content), :remote => true) +
      link_to('remove', section_path(section, :table_of_content_id => section_table_of_content), :method => :delete, :remote => true)
    end
  end
end
