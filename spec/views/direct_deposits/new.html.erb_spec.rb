require 'rails_helper'

RSpec.describe "direct_deposits/new", type: :view do
  before(:each) do
    assign(:direct_deposit, DirectDeposit.new(
      :employee_id => 1,
      :account_number => "MyString",
      :routing_number => "MyString",
      :acct_confirmation => "MyString",
      :admin_id => "MyString",
      :account_type => "MyString"
    ))
  end

  it "renders new direct_deposit form" do
    render

    assert_select "form[action=?][method=?]", direct_deposits_path, "post" do

      assert_select "input#direct_deposit_employee_id[name=?]", "direct_deposit[employee_id]"

      assert_select "input#direct_deposit_account_number[name=?]", "direct_deposit[account_number]"

      assert_select "input#direct_deposit_routing_number[name=?]", "direct_deposit[routing_number]"

      assert_select "input#direct_deposit_acct_confirmation[name=?]", "direct_deposit[acct_confirmation]"

      assert_select "input#direct_deposit_admin_id[name=?]", "direct_deposit[admin_id]"

      assert_select "input#direct_deposit_account_type[name=?]", "direct_deposit[account_type]"
    end
  end
end
