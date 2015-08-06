class DashboardController < ApplicationController
    
    def home
        @current_user = current_user if current_user.present?
        @employee = @current_user.employee if @current_user.present?
        @all_users = User.all
        @orders = Order.where(manager_id: current_user.id) if current_user.present?
        @manager_timesheets = @orders.with_current_timesheets.distinct if current_user.present? && current_user.manager?
        @company = @current_user.company if current_user.present?
        @active_jobs = @company.jobs.active if @company.present?
        @timesheets = @company.timesheets.order(created_at: :desc) if @company.present?
        @employee = current_user.employee if current_user.present? && current_user.employee?
        @job = @employee.current_job if @employee.present?
        @current_shift = @job.current_shift if @employee.present?
        @current_timesheet = @job.current_timesheet if @employee.present?
        skip_authorization
    end
    def company_view
        @company = current_user.company
        @clocked_in = @company.jobs.on_shift
        @timesheets = @company.timesheets
        @payroll_users = @company.payroll_users
        @manager_users = @company.manager_users
        @admin_users = @company.admin_users
        @employee_users = @company.employees.with_active_jobs

        skip_authorization

    end
    def employee_view
        @employee = Employee.find(params[:id])
        skip_authorization
    end
    
    def profile
        @user = current_user
        skip_authorization
    end
    
    
    
end