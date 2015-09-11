require 'rails_helper'

RSpec.describe "events/index", type: :view do
  before(:each) do
    assign(:events, [
      Event.create!(
        :admin_id => 1,
        :action => "Action",
        :eventable_id => 2,
        :eventable_type => "Eventable Type"
      ),
      Event.create!(
        :admin_id => 1,
        :action => "Action",
        :eventable_id => 2,
        :eventable_type => "Eventable Type"
      )
    ])
  end

  it "renders a list of events" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Action".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Eventable Type".to_s, :count => 2
  end
end
