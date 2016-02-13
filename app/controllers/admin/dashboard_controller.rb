class Admin::DashboardController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin_layout'
    
    def owner
      @top_billing = @current_agency.companies.ordered_by_current_bill
      @jobs = @current_agency.jobs 
      @orders = Order.all.paginate(page: params[:page], per_page: 15)
      @timesheets = Timesheet.order(updated_at: :desc) 
      skip_authorization
    end
    def recruiter
      @orders = @current_agency.orders.needs_attention.order(needed_by: :asc).paginate(page: params[:page], per_page: 15)
      @q = @orders.ransack(params[:q]) 
      @candidates = User.available
      
      @hash = Gmaps4rails.build_markers(@orders) do |order, marker|
          marker.lat order.latitude
          marker.lng order.longitude
          marker.infowindow order.title_company
          marker.title order.title
        end
        skip_authorization
    end
    def account_manager
        @orders = Order.all.paginate(page: params[:page], per_page: 15)
        @q = @orders.ransack(params[:q])
        skip_authorization
    end
    
    def tag
      if params[:tag]
        @orders = @current_agency.orders.needs_attention.tagged_with(params[:tag])
        @employees = @current_agency.employees.available.tagged_with(params[:tag])
      else
        @orders = @current_agency.orders.needs_attention
        @employees = @current_agency.employees.available
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
      @timesheets = @current_agency.timesheets.includes(:shifts).distinct
      @jobs = @current_agency.jobs.all
      @shifts = @current_agency.shifts.current_week
      skip_authorization
    end
    
    
    
end