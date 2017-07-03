Fabricator :edition do
  major { |attrs| rand attrs[:books]&.last&.major_version.to_i + 1 }
  minor { |attrs| rand attrs[:books]&.last&.minor_version.to_i + 1 }
  patch { |attrs| rand attrs[:books]&.last&.patch_version.to_i + 1 }
  note { Faker::Hipster.paragraph }
  release { rand 5.years.ago..1.minute.ago }
  pdf { |attrs| attrs[:books]&.last&.pdf }
  book { |attrs| attrs[:books]&.first }
end

Fabricator :complete_edition, :from => :edition do
  books :count => 1
end
