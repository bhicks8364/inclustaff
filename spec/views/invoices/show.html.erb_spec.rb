require 'rails_helper'

RSpec.describe "invoices/show", type: :view do
  before(:each) do
    @invoice = assign(:invoice, Invoice.create!(
      :company_id => 1,
      :agency_id => 2,
      :week => 3,
      :paid => false,
      :total => "9.99",
      :amt_paid => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
  end
end
