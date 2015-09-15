require 'rails_helper'

RSpec.describe "skills/new", type: :view do
  before(:each) do
    assign(:skill, Skill.new(
      :name => "MyString",
      :order_id => 1,
      :required => false
    ))
  end

  it "renders new skill form" do
    render

    assert_select "form[action=?][method=?]", skills_path, "post" do

      assert_select "input#skill_name[name=?]", "skill[name]"

      assert_select "input#skill_order_id[name=?]", "skill[order_id]"

      assert_select "input#skill_required[name=?]", "skill[required]"
    end
  end
end
