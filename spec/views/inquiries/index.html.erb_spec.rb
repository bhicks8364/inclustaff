require 'rails_helper'

RSpec.describe "inquiries/index", type: :view do
  before(:each) do
    assign(:inquiries, [
      Inquiry.create!(
        :name => "Name",
        :job_title => "Job Title",
        :agency_name => "Agency Name",
        :email => "Email",
        :agency_size => "Agency Size",
        :phone_number => "Phone Number"
      ),
      Inquiry.create!(
        :name => "Name",
        :job_title => "Job Title",
        :agency_name => "Agency Name",
        :email => "Email",
        :agency_size => "Agency Size",
        :phone_number => "Phone Number"
      )
    ])
  end

  it "renders a list of inquiries" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Job Title".to_s, :count => 2
    assert_select "tr>td", :text => "Agency Name".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    assert_select "tr>td", :text => "Agency Size".to_s, :count => 2
    assert_select "tr>td", :text => "Phone Number".to_s, :count => 2
  end
end
