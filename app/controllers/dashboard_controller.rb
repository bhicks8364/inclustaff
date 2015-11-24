class DashboardController < ApplicationController

  layout :determine_layout
  
  def home
    #ROOT LANDING PAGE - NO SUBDOMAIN && NO ONE IS SIGNED IN
    if @current_agency.nil? && signed_in? == false
      render 'mainpage'
      @inquiry = Inquiry.new
    end
    #WITH SUBDOMAIN
    #ROOT FOR WHEN A SUBDOMAIN IS PRESENT && NO ONE IS SIGNED IN
    if @current_agency.present? && signed_in? == false
        render 'sign_in_page'
    end
    #ROOT FOR ADMIN DASHBOARDS IF SIGNED IN
    if admin_signed_in? && @current_agency.present?
      # ROUTE TO DASHBOARD BASED ON ROLE
        if current_admin.owner?
          render 'admin/dashboard/owner'
        elsif current_admin.account_manager?
          render 'admin/dashboard/account_manager'
        elsif current_admin.recruiter?
        @jobs = current_admin.jobs.active.paginate(page: params[:page], per_page: 5)
         @timesheets = Timesheet.by_recuriter(current_admin.id)
         @orders = Order.needs_attention.order(:needed_by).paginate(page: params[:page], per_page: 5)
          render 'admin/dashboard/recruiter'
        elsif current_admin.payroll?
        @timesheets = Timesheet.all
          render 'admin/dashboard/payroll'
        else
          render 'admin/dashboard/home'
        end
      @current_admin = current_admin
      #ROOT FOR COMPANY_ADMINS DASHBOARDS IF SIGNED IN
    elsif company_admin_signed_in? && @current_agency.present?
    @current_company_admin = current_company_admin
      @company = current_company_admin.company
      @at_work = @company.jobs.at_work 
         render 'company/dashboard/home'
      
      
    #ROOT TO USER PROFILE WHEN USER SIGNED IN
    elsif user_signed_in? && @current_agency.present?
        @user = current_user
        @employee = @user.employee
        @events = @user.events.applications
        @applications = @events.applications
        render "employee/dashboard/home"
    end
    
        
    
    skip_authorization
  end
  
  def sign_in_page
      skip_authorization
  end
  def features
      skip_authorization
  end
  def contact
      skip_authorization
  end
  def about
      skip_authorization
  end

  
  def company_view
      @admin = current_admin
      @company = @admin.company if @admin.present && @admin.company?
      @jobs = @company.jobs.includes(:employee).active
      @timesheets = @company.timesheets.order(updated_at: :desc)

      @company_admins = @company.admins
      @shifts = @company.shifts

      skip_authorization

  end
  # def employee_view
  #     @employee = current_user.employee if current_user.employee?
  #     @company = @employee.company if @employee.present?
  #     @shifts = @employee.shifts.order(time_in: :desc)
  #     # skip_authorization
  # end
  
  # def profile
  #     @user = current_user
  #     skip_authorization
  # end
  
  def agency_view
      @current_admin = current_admin if admin_signed_in?
      @agency = @current_admin.agency
      @employees = @agency.employees
      @timesheets = @agency.timesheets
      gon.employees = @employees
      gon.company = @company
      gon.timesheets = @timesheets
      skip_authorization
  end

  
  private
    def determine_layout
      if admin_signed_in?
        "admin_layout"
      elsif company_admin_signed_in?
        "company_layout"
      else
          "application"
      end
    end
    
  
  
  
end