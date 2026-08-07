require 'rails_helper'

RSpec.describe ListedItemsHelper, type: :helper do
  let!(:magician) do
    Magician.create!(
      email: 'list-helper@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:list) { List.create!(magician: magician, name: 'Turbo list') }

  before do
    allow(helper).to receive(:current_magician).and_return(magician)
  end

  it 'keeps the add form in a stable Turbo Frame and requests a stream response' do
    html = helper.listed_item_adder(list).to_s

    expect(html).to include("<turbo-frame id=\"#{dom_id(list, :new_item_adder_for)}\"")
    expect(html).to include('data-turbo-stream="true"')
    expect(html).to include('data-turbolinks="false"')
  end

  it 'renders each listed item as a Turbo Frame with stream-powered controls' do
    listed_item = list.listed_items.create!(designation: 'Example item')

    html = helper.listed_item_display(listed_item).to_s

    expect(html).to match(/<turbo-frame[^>]+id=\"#{dom_id(listed_item)}\"/)
    expect(html).to include('data-turbo-method="put"')
    expect(html).to include('data-turbo-stream="true"')
  end
end
