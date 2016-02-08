class Company::DashboardController < ApplicationController
  
  before_filter :authenticate_company_admin!
  before_action :set_company
  layout 'company_layout'
  
  def home
    @company = current_company_admin.company
    @invoices = @company.invoices
    @at_work = @company.jobs.at_work 
    if @current_company_admin.role == "Timeclock"
      render "company/dashboard/timeclock"
    end
  end
  def admins
      
  end
  def admin
      @admin = CompanyAdmin.find(params[:id])
  end
  def timeclock
    # 'entered_code' -> NOT WORKING ATM - Want to do somekind of find_by_code_and_clockin_in all in one thingy
    @entered_code = params[:code]
    @orders = @company.orders.includes(:jobs)
  end
  def clock
    @job = @company.jobs.find(params[:id])
  end
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @current_company_admin = current_company_admin
    @company = @current_company_admin.company
    skip_authorization
  end
    
    
    
end