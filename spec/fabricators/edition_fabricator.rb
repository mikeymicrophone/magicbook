Fabricator :edition do
  book
  major { |attrs| rand attrs[:book].major_version + 1 }
  minor { |attrs| rand attrs[:book].minor_version + 1 }
  patch { |attrs| rand attrs[:book].patch_version + 1 }
  note { Faker::Hipster.paragraph }
  release { rand 5.years.ago..1.minute.ago }
  pdf { |attrs| attrs[:book].pdf }
end
