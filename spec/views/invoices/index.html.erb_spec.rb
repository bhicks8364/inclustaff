require 'rails_helper'

RSpec.describe "invoices/index", type: :view do
  before(:each) do
    assign(:invoices, [
      Invoice.create!(
        :company_id => 1,
        :agency_id => 2,
        :week => 3,
        :paid => false,
        :total => "9.99",
        :amt_paid => "9.99"
      ),
      Invoice.create!(
        :company_id => 1,
        :agency_id => 2,
        :week => 3,
        :paid => false,
        :total => "9.99",
        :amt_paid => "9.99"
      )
    ])
  end

  it "renders a list of invoices" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
  end
end
