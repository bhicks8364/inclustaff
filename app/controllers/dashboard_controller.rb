class DashboardController < ApplicationController

  layout :determine_layout
  
  def home
    @orders = @current_agency.orders.all.paginate(page: params[:page], per_page: 15) if admin_signed_in?
    #ROOT LANDING PAGE - NO SUBDOMAIN && NO ONE IS SIGNED IN
    if @current_agency.nil? && signed_in? == false
      render 'mainpage'
      @inquiry = Inquiry.new
    end
    
    #WITH SUBDOMAIN
    #ROOT FOR WHEN A SUBDOMAIN IS PRESENT && NO ONE IS SIGNED IN
    if @current_agency.present? && signed_in? == false
        @orders = Order.needs_attention.order(:needed_by).paginate(page: params[:page], per_page: 15)
    end
    #ROOT FOR ADMIN DASHBOARDS IF SIGNED IN
    if admin_signed_in? && @current_agency.present?
      # ROUTE TO DASHBOARD BASED ON ROLE
        if current_admin.owner?
          render 'admin/dashboard/owner'
        elsif current_admin.account_manager?
          render 'admin/dashboard/account_manager'
        elsif current_admin.recruiter?
        @q = Order.includes(:company, :jobs).needs_attention.ransack(params[:q]) 
        @jobs = current_admin.jobs.active.paginate(page: params[:page], per_page: 15)
         @timesheets = Timesheet.by_recuriter(current_admin.id)
         
         @orders = Order.needs_attention.order(:needed_by).paginate(page: params[:page], per_page: 15)
          render 'admin/dashboard/recruiter'
        elsif current_admin.payroll?
        @timesheets = Timesheet.all
        @shifts = @current_agency.shifts.today
          render 'admin/dashboard/payroll'
        else
          render 'admin/dashboard/home'
        end
        @hash = Gmaps4rails.build_markers(@orders) do |order, marker|
          marker.lat order.latitude
          marker.lng order.longitude
          marker.infowindow order.title_company
          marker.title order.title
        end
      @current_admin = current_admin
      #ROOT FOR COMPANY_ADMINS DASHBOARDS IF SIGNED IN
    elsif company_admin_signed_in? && @current_agency.present?
    @current_company_admin = current_company_admin
      @company = current_company_admin.company
      @at_work = @company.jobs.at_work 
      @shifts = @company.shifts.today
      @invoices = @company.invoices
         render 'company/dashboard/home'
      
      
    #ROOT TO USER PROFILE WHEN USER SIGNED IN
    elsif user_signed_in? && @current_agency.present?
        @user = current_user
        @employee = @user.employee
        @job = @employee.current_job
        @company = @job.company if @job.present?
        @events = @user.events.applications
        @applications = @events.applications
        render "employee/dashboard/home"
    end
    @orders = Order.needs_attention.order(:needed_by).paginate(page: params[:page], per_page: 15)
     
    
    skip_authorization
  end
  
  def sign_in_page
      skip_authorization
  end
  def features
      skip_authorization
  end
  def contact
      skip_authorization
  end
  def about
      skip_authorization
  end

  
  def company_view
      @admin = current_admin
      @company = @admin.company if @admin.present && @admin.company?
      @jobs = @company.jobs.includes(:employee).active
      @timesheets = @company.timesheets.order(updated_at: :desc)

      @company_admins = @company.admins
      @shifts = @company.shifts

      skip_authorization

  end
  def public_job_board
    @orders = @current_agency.orders.published
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

  
  private
      def determine_layout
      if admin_signed_in?
        "admin_layout"
      elsif company_admin_signed_in?
        "company_layout"
      elsif user_signed_in?
        "employee"
      else
          "application"
      end
    end
    
  
  
  
end