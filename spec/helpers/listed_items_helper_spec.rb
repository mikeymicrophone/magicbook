require 'rails_helper'

RSpec.describe ListedItemsHelper, type: :helper do
  let!(:mage) do
    Mage.create!(
      email: 'list-helper@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
  end
  let!(:list) { List.create!(mage: mage, name: 'Turbo list') }

  before do
    allow(helper).to receive(:current_mage).and_return(mage)
  end

  it 'keeps the add form in a stable Turbo Frame and requests a stream response' do
    html = helper.listed_item_adder(list).to_s

    expect(html).to include("<turbo-frame id=\"#{dom_id(list, :new_item_adder_for)}\"")
    expect(html).to include('class="new_item_adder_for_list"')
    expect(html).to include('data-turbo-stream="true"')
  end

  it 'puts the add-item control inside the adder Turbo Frame so it opens inline' do
    html = helper.listed_item_adder_button(list).to_s
    frame_id = dom_id(list, :new_item_adder_for)

    expect(html).to match(/<turbo-frame[^>]+id="#{Regexp.escape(frame_id)}"[^>]*>.*#{Regexp.escape(new_list_listed_item_path(list))}.*<\/turbo-frame>/m)
    expect(html).to include('Add an item')
    expect(html).to include('data-controller="listed-item-adder"')
    expect(html).to include('data-action="listed-item-adder#show"')
    expect(html).to include('form_for_listed_item')
    expect(html).to include('new_item_adder_for_list hidden')
  end

  it 'renders each listed item as a Turbo Frame with stream-powered controls' do
    listed_item = list.listed_items.create!(designation: 'Example item')

    html = helper.listed_item_display(listed_item).to_s

    expect(html).to match(/<turbo-frame[^>]+id=\"#{dom_id(listed_item)}\"/)
    expect(html).to include('data-turbo-method="put"')
    expect(html).to include('data-turbo-stream="true"')
    expect(html).to include('data-controller="tagging-disclosure"')
    expect(html).to include('aria-label="Tags"')
    expect(html).to include('tagging-disclosure-panel hidden')
    expect(html).to match(%r{/assets/tag[-.]})
  end

  it 'shows applied item chips outside the hidden tagging picker' do
    context = TagContext.create!(name: 'Format', slug: 'item-format', kind: 'user', color: '#3d6b5a')
    tag = context.tags.create!(name: 'Commander', slug: 'commander', kind: 'user')
    listed_item = list.listed_items.create!(designation: 'Example item')
    listed_item.taggings.create!(tag: tag, mage: mage)

    html = helper.listed_item_display(listed_item).to_s
    hidden_at = html.index("tagging-disclosure-panel hidden")

    expect(html).to include("Commander", "tagging-applied", "Add tag")
    expect(html.index("tagging-applied")).to be < hidden_at
    expect(html.index("Commander")).to be < hidden_at
    expect(html[hidden_at..]).to include("Add tag")
    expect(html[hidden_at..]).not_to include("Commander")
  end
end
