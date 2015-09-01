class Employee::DashboardController < ApplicationController
    before_filter :authenticate_user!

    def timeclock
        @employee = current_user.employee if current_user.employee?
        @company = @employee.company if @employee.present?
        @shifts = @employee.shifts.order(time_in: :desc)
    
    end
    
    def home
        @employee = current_user.employee if current_user.employee?
        @shifts = @employee.shifts
        gon.shifts = @shifts
        gon.emp_code = @employee.code
        gon.clocked_in = @employee.clocked_in?
        gon.current_shift = @employee.current_shift
        gon.current_job = @employee.current_job


    end
    
    def employee_view
        @employee = current_user.employee if current_user.employee?
        @timesheets = @employee.timesheets
    end
    
    
    
end