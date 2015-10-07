require 'rails_helper'

RSpec.describe "invoices/new", type: :view do
  before(:each) do
    assign(:invoice, Invoice.new(
      :company_id => 1,
      :agency_id => 1,
      :week => 1,
      :paid => false,
      :total => "9.99",
      :amt_paid => "9.99"
    ))
  end

  it "renders new invoice form" do
    render

    assert_select "form[action=?][method=?]", invoices_path, "post" do

      assert_select "input#invoice_company_id[name=?]", "invoice[company_id]"

      assert_select "input#invoice_agency_id[name=?]", "invoice[agency_id]"

      assert_select "input#invoice_week[name=?]", "invoice[week]"

      assert_select "input#invoice_paid[name=?]", "invoice[paid]"

      assert_select "input#invoice_total[name=?]", "invoice[total]"

      assert_select "input#invoice_amt_paid[name=?]", "invoice[amt_paid]"
    end
  end
end
