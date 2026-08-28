require "rails_helper"

RSpec.describe "tagging:seed" do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?("tagging:seed")
  end

  it "seeds the system tag and Magic starter styles" do
    task = Rake::Task["tagging:seed"]
    task.reenable

    expect { task.invoke }.to change(TagContext, :count).by(5)
      .and change(Tag, :count).by(1)

    expect(TagContext.order(:slug).pluck(:slug)).to eq(%w[era flags format power-level strategy])
  end
end
