class DashboardController < ApplicationController
    # before_filter :authenticate_admin!
    
    def home
        if admin_signed_in? 
           @admin = current_admin
           @company = @admin.company
           @shifts = @company.shifts
           @active_jobs = @company.jobs.active.joins(:shifts).group("jobs.title").order("shifts.updated_at DESC, jobs.title ASC") if @company.jobs.any?
           @timesheets = @company.timesheets.this_week.order(updated_at: :desc)
        elsif user_signed_in? && current_user.not_an_employee?
        
            @current_user = current_user if current_user.present?
            @company = @current_user.company
            @timesheets = @company.timesheets.order(updated_at: :desc)
            @shifts = @company.shifts
            
        elsif user_signed_in? && current_user.employee?
        
            @current_user = current_user if current_user.employee?
            @employee = @current_user.employee if @current_user.employee.present?
            @company = @employee.company if @employee.company.present?
            @timesheets = @employee.timesheets.order(updated_at: :desc)
            @shifts = @employee.shifts
            @job = @employee.current_job 
            @current_timesheet = @employee.timesheets.this_week.last
            @shifts = @current_timesheet.shifts if @current_timesheet.present?
            @current_shift = @current_timesheet.shifts.clocked_in.last  if @current_timesheet.present?
        
        end
        
        # @current_user = current_user if current_user.present?
        # @employee = current_user.employee if current_user.employee?
        # @shifts = @employee.shifts
        # @job = @employee.current_job if @employee.jobs
        # @all_users = User.all
        # @orders = Order.where(manager_id: current_user.id) if current_user.present?
        # @manager_timesheets = @orders.with_current_timesheets.distinct if current_user.present? && current_user.manager?
        # @company = @current_user.company if current_user.present?
        
        # @timesheets = @company.timesheets.order(created_at: :desc) if @company.present?
        # @employee = current_user.employee if current_user.present? && current_user.employee?
        
        # if user_signed_in? && @current_user.employee?
        #     @timesheets = @employee.timesheets.order(updated_at: :desc)
        # elsif user_signed_in? && @current_user.not_an_employee?
        #     @timesheets = @company.timesheets.order(updated_at: :desc)
        # end
        # # @timesheets = @employee.jobs.joins(:timesheets).where(jobs: { employee: @employee }) if @employee.present?

        
        # @current_timesheet = @job.current_timesheet if @employee.present?
        # skip_authorization
    end
    def company_view
        if admin_signed_in? 
          @admin = current_admin
          @company = @admin.company
          @timesheets = @company.timesheets.order(updated_at: :desc)
          @clocked_in = @company.jobs.on_shift.order(updated_at: :desc)
          @admin_users = @company.admins
          # authorize @timesheets
        elsif user_signed_in? && current_user.not_an_employee?
          @current_user = current_user if current_user.present?
          @company = @current_user.company
          @timesheets = @company.timesheets.order(updated_at: :desc)
          # authorize @timesheets
        end
        
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
    end
    
    
    
end