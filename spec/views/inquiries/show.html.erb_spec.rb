require 'rails_helper'

RSpec.describe "inquiries/show", type: :view do
  before(:each) do
    @inquiry = assign(:inquiry, Inquiry.create!(
      :name => "Name",
      :job_title => "Job Title",
      :agency_name => "Agency Name",
      :email => "Email",
      :agency_size => "Agency Size",
      :phone_number => "Phone Number"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Job Title/)
    expect(rendered).to match(/Agency Name/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Agency Size/)
    expect(rendered).to match(/Phone Number/)
  end
end
