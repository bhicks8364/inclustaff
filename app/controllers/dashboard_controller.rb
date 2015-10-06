class DashboardController < ApplicationController
    # before_filter :authenticate_admin!
    layout :determine_layout


    def home
        # authenticate_admin!
        if admin_signed_in? 
            
           @admin = current_admin
           @agency = @admin.agency if @admin.agency?
           @company = @admin.company if @admin.company?
       
           @orders = @agency.orders if @agency.present?
           @orders = @company.orders if @company.present?
           @shifts = @agency.shifts if @agency.present?
           @jobs = @agency.jobs.includes(:employee).order("employee.last_name DESC") if @agency.present?
           @jobs = @company.jobs.active if @company.present?
           @timesheets = @agency.timesheets if @agency.present?
           @timesheets = @company.timesheets if @company.present?
        elsif user_signed_in? && current_user.employee?
            render 'employee_view'
            @current_user = current_user if user_signed_in? && current_user.employee?
            @employee = @current_user.employee if @current_user.present? && @current_user.employee.present?
            
            @work_histories = @employee.work_histories
            @current_shift = @employee.current_shift if @employee.current_shift.present?
            @company = @employee.company if @employee.company.present?
            @timesheets = @employee.timesheets.order(updated_at: :desc)
            @shifts = @employee.shifts
            @job = @employee.current_job 
            @current_timesheet = @employee.timesheets.last
            @shifts = @current_timesheet.shifts if @current_timesheet.present?
        elsif signed_in? == false
            render 'mainpage'
        
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
        skip_authorization
    end
    def company_view
          @admin = current_admin
          @company = @admin.company
          @jobs = @current_admin.company.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 5).order('id DESC')
          @timesheets = @company.timesheets.order(updated_at: :desc)
          @clocked_in = @company.jobs.on_shift.order(time_in: :desc)
          @admin_users = @company.admins
          @shifts = @company.shifts.clocked_out.order(time_out: :desc)
        
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
        @agency = @current_admin.agency
        @employees = @agency.employees
        @timesheets = @agency.timesheets
        gon.employees = @employees
        gon.company = @company
        gon.timesheets = @timesheets
        skip_authorization
    end
    
    def sign_in_page
        skip_authorization
    end
    
    private
      def determine_layout
        current_admin ? "admin_layout" : "application"
      end
    
    
end