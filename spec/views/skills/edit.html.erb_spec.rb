require 'rails_helper'

RSpec.describe "skills/edit", type: :view do
  before(:each) do
    @skill = assign(:skill, Skill.create!(
      :name => "MyString",
      :order_id => 1,
      :required => false
    ))
  end

  it "renders the edit skill form" do
    render

    assert_select "form[action=?][method=?]", skill_path(@skill), "post" do

      assert_select "input#skill_name[name=?]", "skill[name]"

      assert_select "input#skill_order_id[name=?]", "skill[order_id]"

      assert_select "input#skill_required[name=?]", "skill[required]"
    end
  end
end
