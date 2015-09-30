require 'rails_helper'

RSpec.describe "work_histories/show", type: :view do
  before(:each) do
    @work_history = assign(:work_history, WorkHistory.create!(
      :employer_name => "Employer Name",
      :title => "Title",
      :employee_id => 1,
      :description => "MyText",
      :current => false,
      :may_contact => false,
      :supervisor => "Supervisor",
      :phone_number => "Phone Number",
      :pay => "Pay"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Employer Name/)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Supervisor/)
    expect(rendered).to match(/Phone Number/)
    expect(rendered).to match(/Pay/)
  end
end
