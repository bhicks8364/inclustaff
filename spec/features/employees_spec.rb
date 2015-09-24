require 'rails_helper'


RSpec.describe "Employees", type: :feature do
  describe "GET admin/employees" do
    it "display employees" do
      # sign_in(admin)
      visit admin_employees_path
      expect(page).to have_text("all")
    end
  end
  
  
end
