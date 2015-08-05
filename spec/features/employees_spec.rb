require 'rails_helper'


RSpec.describe "Employees", type: :feature do
  describe "GET /employees" do
    it "display employees" do
      
      visit employees_path
      expect(page).to have_text("Hicks")
    end
  end
  
  
end
