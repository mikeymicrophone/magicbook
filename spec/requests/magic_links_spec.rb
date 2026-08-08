require 'rails_helper'

RSpec.describe 'Magic links', type: :request do
  include ActiveJob::TestHelper

  before do
    host! 'example.com'
    ActionMailer::Base.deliveries.clear
    clear_enqueued_jobs
  end

  it 'emails a one-time sign-in link without revealing whether an account exists' do
    mage = Fabricate(:mage, email: 'reader@example.test')

    perform_enqueued_jobs do
      post magic_link_path, params: { email: mage.email }
    end

    expect(response).to redirect_to(new_magic_link_path)
    expect(flash[:notice]).to include('If an account exists')
    expect(ActionMailer::Base.deliveries.last.to).to eq([mage.email])
    expect(ActionMailer::Base.deliveries.last.body.encoded).to include('/magic-link/')

    token = mage.reload.magic_link_token_digest
    expect(token).to be_present

    post magic_link_path, params: { email: 'unknown@example.test' }
    expect(response).to redirect_to(new_magic_link_path)
    expect(flash[:notice]).to include('If an account exists')
  end

  it 'consumes a valid link once and prevents referrer leakage' do
    mage = Fabricate(:mage)
    token = mage.issue_magic_link!

    get consume_magic_link_path(token: token)

    expect(response).to redirect_to(books_path)
    expect(response.headers['Cache-Control']).to eq('no-store')
    expect(response.headers['Referrer-Policy']).to eq('no-referrer')
    expect(mage.reload.magic_link_token_digest).to be_nil
  end
end
