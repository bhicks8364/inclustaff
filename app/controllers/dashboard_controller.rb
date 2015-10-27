class DashboardController < ApplicationController
    # before_filter :authenticate_admin!
    layout :determine_layout
    
    def home
        
        #ROOT LANDING PAGE - NO SUBDOMAIN && NO ONE IS SIGNED IN
        if @current_agency.nil? && signed_in? == false
          render 'mainpage'
          @inquiry = Inquiry.new
        end
        #WITH SUBDOMAIN
        #ROOT FOR WHEN A SUBDOMAIN IS PRESENT && NO ONE IS SIGNED IN
        if @current_agency.present? && signed_in? == false
            @orders = @current_agency.orders.active if @current_agency.present?
            render 'sign_in_page'
        end
      
        #ROOT TO ADMIN DASHBOARD IF SIGNED IN
        if admin_signed_in? && @current_agency.present?
             render 'admin/dashboard/home'
          @current_admin = current_admin
          
        #ROOT TO USER PROFILE WHEN USER SIGNED IN
        elsif user_signed_in? && @current_agency.present?
            @user = current_user
            @employee = @user.employee
            @events = @user.events.applications
            @applications = @events.applications
            render "employee/dashboard/home"
        end
            
        
        skip_authorization
    end
    
    def sign_in_page
        skip_authorization
    end
    def features
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
    # def employee_view
    #     @employee = current_user.employee if current_user.employee?
    #     @company = @employee.company if @employee.present?
    #     @shifts = @employee.shifts.order(time_in: :desc)
    #     # skip_authorization
    # end
    
    # def profile
    #     @user = current_user
    #     skip_authorization
    # end
    
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
        current_admin ? "admin_layout" : "application"
      end
      
    
    
    
end