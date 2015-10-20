class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception
  # before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :update_permitted_parameters, if: :devise_controller?
  # after_action :verify_authorized, unless: :devise_controller?
  
  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  before_action :set_current
  # before_action :get_subdomain
  
  def set_current
    subdomains = request.subdomains
    @current_agency = Agency.where(subdomain: subdomains).first
    # if @current_agency.nil?
    #   not_found
    # end
    @current_admin = current_admin if admin_signed_in?
    # @current = @current_company || @current_agency
    @newly_added = Employee.newly_added.order(created_at: :desc) if @current_agency.present?
    @current = @current_agency if @current_agency.present?
    @at_work = @current.jobs.at_work if @current_admin.present?
    @timesheets = @current.timesheets if @current_admin.present?

    
    
    
    
    
    
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
  # def not_found
  #   # flash[:alert] = "You are not authorized to perform this action."
  #   # redirect_to(root_path)
  #   # redirect_to(request.referrer || root_path)
  #   # flash[:alert] = "Register your agency now!"
  #   render root_path
  #   # raise ActionController::RoutingError.new("Subdomain Not Found. >>  Hey now! You shouldn't be here... You must register if you want to be here :) ")
  # end
  
  def update_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:id, :first_name, :last_name, :email, :role, :can_edit, :company_id, :password, :password_confirmation, :current_password, :address, :city, :state, :zipcode) }
  end
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
  after_filter :user_activity, :admin_activity
  

  def user_activity
    current_user.try :touch
  end
  def admin_activity
    current_admin.try :touch
  end
  
  
end
