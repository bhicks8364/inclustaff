require 'rails_helper'

RSpec.describe "work_histories/index", type: :view do
  before(:each) do
    assign(:work_histories, [
      WorkHistory.create!(
        :employer_name => "Employer Name",
        :title => "Title",
        :employee_id => 1,
        :description => "MyText",
        :current => false,
        :may_contact => false,
        :supervisor => "Supervisor",
        :phone_number => "Phone Number",
        :pay => "Pay"
      ),
      WorkHistory.create!(
        :employer_name => "Employer Name",
        :title => "Title",
        :employee_id => 1,
        :description => "MyText",
        :current => false,
        :may_contact => false,
        :supervisor => "Supervisor",
        :phone_number => "Phone Number",
        :pay => "Pay"
      )
    ])
  end

  it "renders a list of work_histories" do
    render
    assert_select "tr>td", :text => "Employer Name".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Supervisor".to_s, :count => 2
    assert_select "tr>td", :text => "Phone Number".to_s, :count => 2
    assert_select "tr>td", :text => "Pay".to_s, :count => 2
  end
end
