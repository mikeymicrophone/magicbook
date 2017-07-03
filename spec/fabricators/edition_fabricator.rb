Fabricator :edition do
  books :count => 1
  major { |attrs| rand attrs[:books].last.major_version + 1 }
  minor { |attrs| rand attrs[:books].last.minor_version + 1 }
  patch { |attrs| rand attrs[:books].last.patch_version + 1 }
  note { Faker::Hipster.paragraph }
  release { rand 5.years.ago..1.minute.ago }
  pdf { |attrs| attrs[:books].last.pdf }
end
