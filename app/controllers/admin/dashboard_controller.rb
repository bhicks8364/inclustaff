class Admin::DashboardController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin_layout'
    
    def owner

      @current_agency = current_admin.agency
      @jobs = @current_agency.jobs if @current_agency.present?
      
      @orders = Order.all
    
      @timesheets = Timesheet.order(updated_at: :desc) 
  
  
        skip_authorization
    end
    def recruiter
      if current_admin.recruiter?
       
     
        @jobs = current_admin.jobs.active.paginate(page: params[:page], per_page: 5)
       
        @timesheets = Timesheet.by_recuriter(current_admin.id)
      else
        @jobs = Job.all.paginate(page: params[:page], per_page: 5)
        @timesheets = Timesheet.current_week
      end
      @orders = Order.needs_attention.order(:needed_by).paginate(page: params[:page], per_page: 5)
        @current_recruiter = @current_admin if @current_admin.recruiter?
        @recruiter_jobs = @current_recruiter.jobs.by_recuriter(@current_recruiter.id) if @current_admin.recruiter?
        
        skip_authorization
    end
    def account_manager
      if current_admin.account_manager?
        @orders = current_admin.account_orders.all.paginate(page: params[:page], per_page: 5)
      else
        @orders = Order.all.paginate(page: params[:page], per_page: 5)
      end
        skip_authorization
    end
    
    def tag
      if params[:tag]
        @orders = Order.needs_attention.tagged_with(params[:tag])
        @employees = Employee.unassigned.tagged_with(params[:tag])
      else
        @orders = Order.needs_attention
        @employees = Employee.unassigned
      end
      skip_authorization
    end
    def all_tags
      if params[:tag]
        @orders = @current_agency.orders.needs_attention.tagged_with(params[:tag])
        @employees = @current_agency.employees.available.tagged_with(params[:tag])
      else
        @orders = @current_agency.orders.needs_attention
        @employees = @current_agency.employees.available
      end
      skip_authorization
    end
    def home
      gon.invoices = @current_agency.invoices.pluck(:total)
    #   @admin = current_admin
    # #   @company = @admin.company
    #   @agency = @admin.agency
       
    #   @orders = @agency.orders
    #   @shifts = @agency.shifts
    #   @jobs = @agency.jobs.active.joins(:shifts).group("jobs.title").order("shifts.updated_at DESC, jobs.title ASC") if @company.jobs.any?
      @timesheets = @current_agency.timesheets
        skip_authorization
    end
    def company_view

      @viewing = @current_company || @current_agency
      @timesheets = @viewing.timesheets if @viewing.present?
      @clock_ins = @viewing.admin_events.clock_ins.order('id DESC')
      @clock_outs = @viewing.admin_events.clock_outs.order('id DESC')
      @applications = @viewing.order_events.applications
      @jobs = @current.jobs.includes(:employee, :company) if @current.present?
      # @clocked_in = @jobs.on_shift.order(time_in: :desc)
      # @newly_added = @viewing.employees.newly_added.order(created_at: :desc)
      @orders = @viewing.orders if @viewing.present?

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
    
   
    
    def payroll
      @admin = @current_admin
      
      @timesheets = @current_agency.timesheets.all
      @jobs = @current_agency.jobs.all
      
      skip_authorization
    end
    
    
    
end