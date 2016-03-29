require 'rails_helper'

RSpec.describe "direct_deposits/index", type: :view do
  before(:each) do
    assign(:direct_deposits, [
      DirectDeposit.create!(
        :employee_id => 1,
        :account_number => "Account Number",
        :routing_number => "Routing Number",
        :acct_confirmation => "Acct Confirmation",
        :admin_id => "Admin",
        :account_type => "Account Type"
      ),
      DirectDeposit.create!(
        :employee_id => 1,
        :account_number => "Account Number",
        :routing_number => "Routing Number",
        :acct_confirmation => "Acct Confirmation",
        :admin_id => "Admin",
        :account_type => "Account Type"
      )
    ])
  end

  it "renders a list of direct_deposits" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Account Number".to_s, :count => 2
    assert_select "tr>td", :text => "Routing Number".to_s, :count => 2
    assert_select "tr>td", :text => "Acct Confirmation".to_s, :count => 2
    assert_select "tr>td", :text => "Admin".to_s, :count => 2
    assert_select "tr>td", :text => "Account Type".to_s, :count => 2
  end
end
