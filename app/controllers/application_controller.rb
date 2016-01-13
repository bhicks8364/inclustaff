class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception
  # before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :update_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?
  
  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  before_action :set_current
  
  def set_current
    subdomains = request.subdomains
    @current_agency = Agency.where(subdomain: subdomains).first
    @current_admin = current_admin if admin_signed_in?
    @current_user = current_user if user_signed_in?
    @current_company = current_company_admin.company if company_admin_signed_in?
    @newly_added = @current_agency.employees.newly_added.order(created_at: :desc) if @current_agency.present?
    @newly_added = @current_company.employees.newly_added.order(created_at: :desc) if @current_company.present?
    @on_shift = @current_company.jobs.on_shift.order(time_in: :asc) if @current_company.present?

    @current = @current_user || @current_admin || @current_company_admin
    @signed_in = @current
    @q_orders = @current_agency.orders.includes(:company, :jobs).active.ransack(params[:q]) if admin_signed_in?
  end

  def after_sign_in_path_for(resource)
      resource
  end
  
  private
  # def not_found
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
  def company_admin_activity
    current_company_admin.try :touch
  end
  
  
end
