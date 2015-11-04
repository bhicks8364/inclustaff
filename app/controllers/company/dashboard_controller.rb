class Company::DashboardController < ApplicationController
  
  before_filter :authenticate_company_admin!
  before_action :set_company
  layout 'application'
  
  def home
    @company = current_company_admin.company
      
  end
  def admins
      
  end
  def admin
      @admin = CompanyAdmin.find(params[:id])
  end
  def timeclock
    # 'entered_code' -> NOT WORKING ATM - Want to do somekind of find_by_code_and_clockin_in all in one thingy
    @entered_code = params[:code]
  end
  def clock
    @job = @company.jobs.find(params[:id])
  end
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @current_company_admin = current_company_admin
    @company = @current_company_admin.company
  end
    
    
    
end