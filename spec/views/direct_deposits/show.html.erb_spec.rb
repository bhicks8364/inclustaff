require 'rails_helper'

RSpec.describe "direct_deposits/show", type: :view do
  before(:each) do
    @direct_deposit = assign(:direct_deposit, DirectDeposit.create!(
      :employee_id => 1,
      :account_number => "Account Number",
      :routing_number => "Routing Number",
      :acct_confirmation => "Acct Confirmation",
      :admin_id => "Admin",
      :account_type => "Account Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Account Number/)
    expect(rendered).to match(/Routing Number/)
    expect(rendered).to match(/Acct Confirmation/)
    expect(rendered).to match(/Admin/)
    expect(rendered).to match(/Account Type/)
  end
end
