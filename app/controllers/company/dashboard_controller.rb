class Company::DashboardController < ApplicationController

  before_filter :authenticate_company_admin!
  before_action :set_company
  layout 'company_layout'

  def home
    @invoices = @company.invoices
    @clocked_in = @company.jobs.at_work.distinct
    @clocked_out = @company.jobs.currently_working.without_current_shifts
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
    @clocked_in = @company.jobs.includes(:employee).at_work.order("employees.last_name")
    @clocked_out = @company.jobs.currently_working.without_current_shifts.order("employees.last_name")
    # 'entered_code' -> NOT WORKING ATM - Want to do somekind of find_by_code_and_clockin_in all in one thingy
    # @entered_code = params[:code] if params[:code].present?
    # @job = @company.users.where(code: @entered_code).first if params[:code].present?
    # if @job.present?
    #   @employee_code = @job.employee.code 
    #   @orders = @company.orders.includes(:jobs)
    #   @state = @job.on_shift? ? true : false
    #   authorized = (@entered_code === @employee_code) ? true : false
    # end
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
