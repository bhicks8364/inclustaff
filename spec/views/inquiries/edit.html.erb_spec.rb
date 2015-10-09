require 'rails_helper'

RSpec.describe "inquiries/edit", type: :view do
  before(:each) do
    @inquiry = assign(:inquiry, Inquiry.create!(
      :name => "MyString",
      :job_title => "MyString",
      :agency_name => "MyString",
      :email => "MyString",
      :agency_size => "MyString",
      :phone_number => "MyString"
    ))
  end

  it "renders the edit inquiry form" do
    render

    assert_select "form[action=?][method=?]", inquiry_path(@inquiry), "post" do

      assert_select "input#inquiry_name[name=?]", "inquiry[name]"

      assert_select "input#inquiry_job_title[name=?]", "inquiry[job_title]"

      assert_select "input#inquiry_agency_name[name=?]", "inquiry[agency_name]"

      assert_select "input#inquiry_email[name=?]", "inquiry[email]"

      assert_select "input#inquiry_agency_size[name=?]", "inquiry[agency_size]"

      assert_select "input#inquiry_phone_number[name=?]", "inquiry[phone_number]"
    end
  end
end
