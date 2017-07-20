Fabricator :table_of_content do
  book
  edition
end

Fabricator :chapter_of_content, :from => :table_of_content do
  book
  edition
  chapter
end

Fabricator :section_of_content, :from => :chapter_of_content do
  section
end

Fabricator :paragraph_of_content, :from => :section_of_content do
  paragraph
end

Fabricator :citation_of_content, :from => :paragraph_of_content do 
  citation
end
