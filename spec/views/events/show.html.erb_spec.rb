require 'rails_helper'

RSpec.describe "events/show", type: :view do
  before(:each) do
    @event = assign(:event, Event.create!(
      :admin_id => 1,
      :action => "Action",
      :eventable_id => 2,
      :eventable_type => "Eventable Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Action/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Eventable Type/)
  end
end
