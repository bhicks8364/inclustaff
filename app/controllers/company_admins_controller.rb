class CompanyAdminsController < ApplicationController
    layout :determine_layout
    
    def index
        if admin_signed_in?
            @company_admins = CompanyAdmin.all
        elsif company_admin_signed_in?
            @company_admins = @current_company.admins.all
        end
        gon.admins = CompanyAdmin.all
        gon.jbuilder
        skip_authorization
    end
    
    def show
      @company_admin = CompanyAdmin.find(params[:id])
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
      elsif company_admin_signed_in?
        "company_layout"
      else
          "application"
      end
    end
end
