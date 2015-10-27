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
    def recruiter
        @current_recruiter = @current_admin if @current_admin.recruiter?
        @recruiter_jobs = @current.jobs.by_recuriter(@current_recruiter.id)
        @q = Skill.includes(:skillable).ransack(params[:q])
        @searched_skills = @q.result(distinct: true)
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
    end
    def all_tags
      if params[:tag]
        @orders = Order.needs_attention.tagged_with(params[:tag])
        @employees = Employee.unassigned.tagged_with(params[:tag])
      else
        @orders = Order.needs_attention
        @employees = Employee.unassigned
      end
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
    
    def agency_view
       
        @clock_ins = @current_agency.admin_events.clock_ins.order('id DESC')
        @clock_outs = @current_agency.admin_events.clock_outs.order('id DESC')
        @applications = @current_agency.order_events.applications
        
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
      @jobs = @current.jobs.active if @current.jobs.any?
      @agency_jobs = @jobs
      skip_authorization
    end
    
    
    
end