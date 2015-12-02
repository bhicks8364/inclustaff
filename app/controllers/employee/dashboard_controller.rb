class Employee::DashboardController < ApplicationController
    before_filter :authenticate_user!
    before_action :set_employee
    
    layout 'employee'
    def timeclock
        
        @company = @employee.company if @employee.present?
        @shifts = @employee.shifts.order(time_in: :desc)
        
    end
    
    def home
        
        @shifts = @employee.shifts
        @jobs = @employee.jobs
        @orders = Order.active
        gon.shifts = @shifts
        gon.emp_code = @employee.code
        gon.clocked_in = @employee.clocked_in?
        gon.current_shift = @employee.current_shift
        gon.current_job = @employee.current_job
       

    end
    
    def employee_view
        
        @timesheets = @employee.timesheets
        
    end
    def jobs
       @orders = @current_agency.orders.needs_attention
    end
    def profile
       @skill = @employee.skills.new
       @work_histories = @employee.work_histories
       
    end
    
    private
    
    def set_employee
        @user = current_user
        @employee = @user.employee
        skip_authorization
    end
    
    
    
end