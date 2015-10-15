class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception
  # before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :update_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?
  
  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  before_action :set_current, unless: :devise_controller?
  
  
  def set_current
    if admin_signed_in? && current_admin.agency?
      @current_agency = Agency.find(current_admin.agency_id)
      @agency_jobs = @current_agency.jobs if @current_agency.present?
    elsif admin_signed_in? && current_admin.company?
      @current_company = Company.find(current_admin.company_id)
      @company_agency = @current_company.agency if @current_company.present?
      @company_jobs = @current_company.jobs if @current_company.present?
    else
      
    end
    @current_admin = current_admin
    @current = @current_company || @current_agency
    @newly_added = Employee.newly_added.order(created_at: :desc) if @current_agency.present?
    @at_work = @current.jobs.at_work if @current.present?
    
    
    
    
    
  end

  # def after_sign_in_path_for(resource)
  #   # check for the class of the object to determine what type it is
  #   case resource.class
  #   when Admin
  #     redirect_to root_path  
  #   when User
  #     redirect_to root_path
  #   end
  # end
  
  private
  
  
  
  def update_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:id, :first_name, :last_name, :email, :role, :can_edit, :company_id, :password, :password_confirmation, :current_password, :address, :city, :state, :zipcode) }
  end
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
  after_filter :user_activity

  def user_activity
    current_user.try :touch
  end
  
  
end
