class Admin::DashboardController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin_layout'
    
    def owner
      # @admin = @current_admin if admin_signed_in?
      # if @admin.agency?
      #   @agency = @admin.agency
      #   @events = @agency.events.order('id DESC').limit(5)
      # elsif @admin.company?
      #   @company = @admin.company
      #   @events = @company.events.order('id DESC').limit(5)
      # end
      @current_agency = current_admin.agency
      @jobs = @current_agency.jobs if @current_agency.present?
      
      @orders = @company.orders if @company.present?
      @orders = @agency.orders if @agency.present?
      # @jobs = @company.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @current_company.present?
      # @jobs = @agency.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @current_agency.present?
      @timesheets = @company.timesheets.order(created_at: :desc) if @company.present?
      @timesheets = @agency.timesheets.order(created_at: :desc) if @agency.present?
  
  
        skip_authorization
    end
    def home
    #   @admin = current_admin
    # #   @company = @admin.company
    #   @agency = @admin.agency
       
    #   @orders = @agency.orders
    #   @shifts = @agency.shifts
    #   @jobs = @agency.jobs.active.joins(:shifts).group("jobs.title").order("shifts.updated_at DESC, jobs.title ASC") if @company.jobs.any?
    #   @timesheets = @agency.timesheets
        skip_authorization
    end
    def company_view

        @viewing = @current_company || @current_agency
        @timesheets = @viewing.timesheets if @viewing.present?
        @events = @viewing.events.order('id DESC').limit(5)
      # end
      
      # @timesheets = @company.timesheets.order(created_at: :desc) if @company.present?
      # @timesheets = @agency.timesheets.order(created_at: :desc) if @agency.present?
      # @jobs = @company.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @company.present?
      # # @jobs = @agency.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 10).order('id DESC') if @agency.present?
      @jobs = @viewing.jobs.includes(:employee, :company) if @viewing.present?
      @clocked_in = @jobs.on_shift.order(time_in: :desc)
      @newly_added = @viewing.employees.newly_added.order(created_at: :desc)
      # # @admin_users = @company.admins
      # # @shifts = @company.shifts.order(updated_at: :desc)
      # @employees = @company.employees if @company.present?
      # @employees = @agency.employees if @agency.present?
      @orders = @viewing.orders if @viewing.present?
      # @orders = @agency.orders if @agency.present?
        
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
       
        
        @employees = @company.employees if @company.present?
        @timesheets = @company.timesheets if @company.present?
        @jobs = @company.jobs.active if @company.present?
        @jobs = @current_agency.jobs.active if @current_agency.present?
        @orders = @company.orders if @company.present?
        @orders = @current_agency.orders if @current_agency.present?
        @employees = @current_agency.employees if @current_agency.present?
        @timesheets = @current_agency.timesheets if @current_agency.present?
        gon.employees = @employees
        gon.company = @company
        gon.timesheets = @timesheets
        skip_authorization
    end
    
    def payroll
      @admin = @current_admin
      @agency = @current_agency
      @timesheets = @agency.timesheets
      @jobs = @agency_jobs.active if @agency_jobs.any?
      skip_authorization
    end
    
    
    
end