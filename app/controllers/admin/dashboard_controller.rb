class Admin::DashboardController < ApplicationController
    before_filter :authenticate_admin!
    
    def home
       @admin = current_admin
       @company = @admin.company
       
       
       @orders = @company.orders
       @shifts = @company.shifts
       @jobs = @company.jobs.active.joins(:shifts).group("jobs.title").order("shifts.updated_at DESC, jobs.title ASC") if @company.jobs.any?
       @timesheets = @company.timesheets
        
    end
    def company_view
          @admin = current_admin
          @company = @admin.company
          @jobs = @current_admin.company.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 5).order('id DESC')
          @timesheets = @company.timesheets.order(updated_at: :desc)
          @clocked_in = @company.jobs.on_shift.order(time_in: :desc)
          @admin_users = @company.admins
          @shifts = @company.shifts.order(updated_at: :desc)
          @employees = @company.employees
        
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