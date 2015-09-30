require 'rails_helper'

RSpec.describe "work_histories/new", type: :view do
  before(:each) do
    assign(:work_history, WorkHistory.new(
      :employer_name => "MyString",
      :title => "MyString",
      :employee_id => 1,
      :description => "MyText",
      :current => false,
      :may_contact => false,
      :supervisor => "MyString",
      :phone_number => "MyString",
      :pay => "MyString"
    ))
  end

  it "renders new work_history form" do
    render

    assert_select "form[action=?][method=?]", work_histories_path, "post" do

      assert_select "input#work_history_employer_name[name=?]", "work_history[employer_name]"

      assert_select "input#work_history_title[name=?]", "work_history[title]"

      assert_select "input#work_history_employee_id[name=?]", "work_history[employee_id]"

      assert_select "textarea#work_history_description[name=?]", "work_history[description]"

      assert_select "input#work_history_current[name=?]", "work_history[current]"

      assert_select "input#work_history_may_contact[name=?]", "work_history[may_contact]"

      assert_select "input#work_history_supervisor[name=?]", "work_history[supervisor]"

      assert_select "input#work_history_phone_number[name=?]", "work_history[phone_number]"

      assert_select "input#work_history_pay[name=?]", "work_history[pay]"
    end
  end
end
