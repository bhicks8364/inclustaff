class CompanyAdminsController < ApplicationController
    layout :determine_layout
    
    def index
        if admin_signed_in?
          @q = CompanyAdmin.real_users.includes(:company).ransack(params[:q]) 
  
           @company_admins = @q.result(distinct: true).order('companies.name').paginate(page: params[:page], per_page: 10) if @q.present?
           @timeclocks = CompanyAdmin.timeclocks.includes(:company).order('companies.name').paginate(page: params[:page], per_page: 10)
        elsif company_admin_signed_in?
            @company_admins = @current_company.admins.real_users.paginate(page: params[:page], per_page: 10) 
            @q = @company_admins.includes(:company).ransack(params[:q]) 
        end
        gon.admins = CompanyAdmin.real_users
        skip_authorization
    end
    
    def show
      @company_admin = CompanyAdmin.find(params[:id])
      @company = @company_admin.company
      if @company_admin.role == "Timeclock"
        render "company/dashboard/timeclock"
      end
      skip_authorization
    end
    
    def follow
      @company_admin = CompanyAdmin.find(params[:id])
      @event = current_company_admin.events.create(action: "followed", eventable: @company_admin)
      if @event.save
        redirect_to admins_path, notice: 'You are now following ' + "#{@company_admin.name}"
      else
        redirect_to admins_path, notice: 'Unable to follow ' + "#{@company_admin.name}"
      end
      skip_authorization
    end
    
    
    
    private
    def determine_layout
      if admin_signed_in?
        "admin_layout"
      elsif company_admin_signed_in? && !current_company_admin.role == "Timeclock"
        "company_layout"
      elsif company_admin_signed_in? && current_company_admin.role == "Timeclock"
        "timeclock"
      else
          "application"
      end
    end
end
