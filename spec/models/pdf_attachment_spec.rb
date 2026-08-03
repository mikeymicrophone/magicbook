require "rails_helper"

RSpec.describe "PDF attachments" do
  it "stores book PDFs with Active Storage" do
    book = Book.new

    book.pdf.attach(io: StringIO.new("pdf"), filename: "book.pdf", content_type: "application/pdf")

    expect(book.pdf).to be_attached
  end

  it "stores edition PDFs with Active Storage" do
    edition = Edition.new

    edition.pdf.attach(io: StringIO.new("pdf"), filename: "edition.pdf", content_type: "application/pdf")

    expect(edition.pdf).to be_attached
  end
end
