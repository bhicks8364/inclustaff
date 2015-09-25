class Employee::DashboardController < ApplicationController
    before_filter :authenticate_user!
    layout 'new_employee'
    def timeclock
        @employee = current_user.employee if current_user.employee?
        @company = @employee.company if @employee.present?
        @shifts = @employee.shifts.order(time_in: :desc)
        skip_authorization
    end
    
    def home
        @employee = current_user.employee if current_user.employee?
        @shifts = @employee.shifts
        gon.shifts = @shifts
        gon.emp_code = @employee.code
        gon.clocked_in = @employee.clocked_in?
        gon.current_shift = @employee.current_shift
        gon.current_job = @employee.current_job
        skip_authorization

    end
    
    def employee_view
        @employee = current_user.employee if current_user.employee?
        @timesheets = @employee.timesheets
        skip_authorization
    end
    
    
    
end