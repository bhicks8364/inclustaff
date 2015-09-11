class Admin::DashboardController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin_layout'
    def owner
       @admin = current_admin
      if @admin.agency?
        @agency = @admin.agency
        @events = @agency.events
      elsif @admin.company?
        @company = @admin.company
        @events = @company.events
      end
      
      @orders = @company.orders if @company.present?
      @orders = @agency.orders if @agency.present?
      @jobs = @company.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @company.present?
      @jobs = @agency.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @agency.present?
      @timesheets = @company.timesheets.order(created_at: :desc) if @company.present?
      @timesheets = @agency.timesheets.order(created_at: :desc) if @agency.present?
  
  
        skip_authorization
    end
    def home
       @admin = current_admin
    #   @company = @admin.company
       @agency = @admin.agency
       
       @orders = @agency.orders
       @shifts = @agency.shifts
       @jobs = @agency.jobs.active.joins(:shifts).group("jobs.title").order("shifts.updated_at DESC, jobs.title ASC") if @company.jobs.any?
       @timesheets = @agency.timesheets
        skip_authorization
    end
    def company_view
      @admin = current_admin
      if @admin.agency?
        @agency = @admin.agency
        @events = @agency.events
      elsif @admin.company?
        @company = @admin.company
        @events = @company.events
      end
      
      @timesheets = @company.timesheets.order(created_at: :desc) if @company.present?
      @timesheets = @agency.timesheets.order(created_at: :desc) if @agency.present?
      @jobs = @company.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @company.present?
      # @jobs = @agency.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @agency.present?
      @jobs = @agency.jobs.includes(:employee, :company).order('id DESC') if @agency.present?
      @clocked_in = @jobs.on_shift.order(time_in: :desc)
      # @admin_users = @company.admins
      # @shifts = @company.shifts.order(updated_at: :desc)
      @employees = @company.employees if @company.present?
      @employees = @agency.employees if @agency.present?
      @orders = @company.orders if @company.present?
      @orders = @agency.orders if @agency.present?
        
        # @timesheets = @company.timesheets.order(updated_at: :desc)
        # @payroll_users = @company.payroll_users
        # @manager_users = @company.manager_users
        
        # @employee_users = @company.employees.with_active_jobs

        skip_authorization

    end
    def employee_view
        @employee = current_user.employee if current_user.employee?
        @company = @employee.company if @employee.present?
        @shifts = @employee.shifts.order(time_in: :desc)
        # skip_authorization
    end
    
    def profile
        @user = current_user
        skip_authorization
    end
    
    def agency_view
        @current_admin = current_admin if admin_signed_in?
        @company = @current_admin.company
        @employees = @company.employees
        @timesheets = @company.timesheets
        gon.employees = @employees
        gon.company = @company
        gon.timesheets = @timesheets
    end
    
    
    
end