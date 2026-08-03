namespace :editor do
  desc 'Reset a small, isolated book for manually testing the publishing editor'
  task reset_sandbox: :environment do
    unless Rails.env.development? || ENV['EDITOR_SANDBOX_ENABLED'] == 'true'
      abort 'The editor sandbox can run only in development or with EDITOR_SANDBOX_ENABLED=true.'
    end

    Book.transaction do
      book = Book.find_or_initialize_by(title: 'Editor Sandbox')
      book.assign_attributes(
        author: 'Ways We Mage',
        version: '0.1.0',
        price_cents: 0
      )
      book.save!
      book.table_of_contents.destroy_all

      edition = Edition.create!(major: 0, minor: 1, patch: 0, release: 1.day.ago)
      TableOfContent.create!(book: book, edition: edition)

      first_chapter = Chapter.create!(title: 'First chapter', subtitle: 'Ordering within a chapter')
      TableOfContent.create!(book: book, edition: edition, chapter: first_chapter)

      first_section = Section.create!(heading: 'First section', subheading: 'Paragraph and citation actions')
      second_section = Section.create!(heading: 'Second section', subheading: 'A destination for delay')
      TableOfContent.create!(book: book, edition: edition, chapter: first_chapter, section: first_section)
      TableOfContent.create!(book: book, edition: edition, chapter: first_chapter, section: second_section)

      first_paragraph = Paragraph.create!(text: 'This is the first sandbox paragraph. Edit, promote, or delay it.')
      second_paragraph = Paragraph.create!(text: 'This is the second sandbox paragraph. It gives the first paragraph a destination.')
      TableOfContent.create!(book: book, edition: edition, chapter: first_chapter, section: first_section, paragraph: first_paragraph)
      TableOfContent.create!(book: book, edition: edition, chapter: first_chapter, section: first_section, paragraph: second_paragraph)

      first_citation = Citation.create!(finding: 'First sandbox citation', source: 'Editor Sandbox')
      second_citation = Citation.create!(finding: 'Second sandbox citation', source: 'Editor Sandbox')
      TableOfContent.create!(book: book, edition: edition, chapter: first_chapter, section: first_section, paragraph: first_paragraph, citation: first_citation)
      TableOfContent.create!(book: book, edition: edition, chapter: first_chapter, section: first_section, paragraph: first_paragraph, citation: second_citation)

      second_chapter = Chapter.create!(title: 'Second chapter', subtitle: 'A destination for section delay')
      TableOfContent.create!(book: book, edition: edition, chapter: second_chapter)
      destination_section = Section.create!(heading: 'Destination section', subheading: 'For moving a section forward')
      TableOfContent.create!(book: book, edition: edition, chapter: second_chapter, section: destination_section)
      destination_paragraph = Paragraph.create!(text: 'This paragraph lets you test moving content across sections.')
      TableOfContent.create!(book: book, edition: edition, chapter: second_chapter, section: destination_section, paragraph: destination_paragraph)

      puts "Editor Sandbox reset. Sign in as a scribe and open #{Rails.application.routes.url_helpers.edit_book_path(book)}"
    end
  end

  desc 'Create a local skydiving author account and an editable demo book'
  task seed_skydiving: :environment do
    abort 'The skydiving demo can run only in development.' unless Rails.env.development?

    Book.transaction do
      scribe = Scribe.find_or_initialize_by(email: 'skydiving@example.com')
      scribe.password = 'skydiving'
      scribe.password_confirmation = 'skydiving'
      scribe.confirmed_at ||= Time.current
      scribe.save!

      book = Book.find_or_initialize_by(title: 'Skydiving: First Jump Fundamentals')
      book.assign_attributes(
        author: 'Skydiving Demo',
        version: '0.1.0',
        price_cents: 0
      )
      book.save!
      book.table_of_contents.destroy_all

      edition = Edition.create!(major: 0, minor: 1, patch: 0, release: 1.day.ago)
      TableOfContent.create!(book: book, edition: edition)

      preparation = Chapter.create!(title: 'Before the Jump', subtitle: 'Calm preparation turns information into muscle memory')
      TableOfContent.create!(book: book, edition: edition, chapter: preparation)

      ground_school = Section.create!(heading: 'Ground school', subheading: 'The small decisions that happen before the aircraft climbs')
      door = Section.create!(heading: 'At the door', subheading: 'A short sequence for the moment the wind gets loud')
      TableOfContent.create!(book: book, edition: edition, chapter: preparation, section: ground_school)
      TableOfContent.create!(book: book, edition: edition, chapter: preparation, section: door)

      briefing = Paragraph.create!(text: 'A first jump begins on the ground. Rehearse the exit, the altitude checks, and the response to a deployment problem until each step feels ordinary. The goal is not bravado; it is making a clear decision when the airplane is noisy and the clock is moving.')
      partnership = Paragraph.create!(text: 'Treat your instructor as part of the system, not as a spectator. Say the plan out loud, ask for the signal you will use if something changes, and make sure the landing area and wind plan are familiar before boarding.')
      TableOfContent.create!(book: book, edition: edition, chapter: preparation, section: ground_school, paragraph: briefing)
      TableOfContent.create!(book: book, edition: edition, chapter: preparation, section: ground_school, paragraph: partnership)

      TableOfContent.create!(
        book: book, edition: edition, chapter: preparation, section: ground_school, paragraph: briefing,
        citation: Citation.create!(finding: 'Training and equipment procedures vary by drop zone; follow your instructor and local rules.', source: 'Skydiving demo note')
      )
      TableOfContent.create!(
        book: book, edition: edition, chapter: preparation, section: ground_school, paragraph: briefing,
        citation: Citation.create!(finding: 'This sample text is for editor testing, not operational skydiving instruction.', source: 'Skydiving demo note')
      )

      exit = Paragraph.create!(text: 'At the door, simplify. Check in with your instructor, find the correct body position, and use the practiced count. Let the airflow support the position you trained rather than trying to invent a better one in the moment.')
      TableOfContent.create!(book: book, edition: edition, chapter: preparation, section: door, paragraph: exit)

      flight = Chapter.create!(title: 'In the Air', subtitle: 'From stable freefall to a deliberate landing pattern')
      TableOfContent.create!(book: book, edition: edition, chapter: flight)
      canopy = Section.create!(heading: 'Canopy flight', subheading: 'Look outward, preserve options, and land with room to spare')
      TableOfContent.create!(book: book, edition: edition, chapter: flight, section: canopy)
      landing = Paragraph.create!(text: 'Once the canopy opens, pause long enough to confirm that it is flying normally. Locate the landing area, compare your altitude to the planned pattern, and favor a conservative choice with open space over a clever correction close to the ground.')
      debrief = Paragraph.create!(text: 'A useful debrief names one thing that worked and one thing to practice next. Capture the details while they are fresh, then turn the next jump into a focused repetition rather than a test of memory.')
      TableOfContent.create!(book: book, edition: edition, chapter: flight, section: canopy, paragraph: landing)
      TableOfContent.create!(book: book, edition: edition, chapter: flight, section: canopy, paragraph: debrief)

      puts "Skydiving demo reset. Sign in at /scribes/sign_in with skydiving@example.com / skydiving, then open #{Rails.application.routes.url_helpers.edit_book_path(book)}"
    end
  end
end
