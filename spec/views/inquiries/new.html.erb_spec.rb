require 'rails_helper'

RSpec.describe "inquiries/new", type: :view do
  before(:each) do
    assign(:inquiry, Inquiry.new(
      :name => "MyString",
      :job_title => "MyString",
      :agency_name => "MyString",
      :email => "MyString",
      :agency_size => "MyString",
      :phone_number => "MyString"
    ))
  end

  it "renders new inquiry form" do
    render

    assert_select "form[action=?][method=?]", inquiries_path, "post" do

      assert_select "input#inquiry_name[name=?]", "inquiry[name]"

      assert_select "input#inquiry_job_title[name=?]", "inquiry[job_title]"

      assert_select "input#inquiry_agency_name[name=?]", "inquiry[agency_name]"

      assert_select "input#inquiry_email[name=?]", "inquiry[email]"

      assert_select "input#inquiry_agency_size[name=?]", "inquiry[agency_size]"

      assert_select "input#inquiry_phone_number[name=?]", "inquiry[phone_number]"
    end
  end
end
