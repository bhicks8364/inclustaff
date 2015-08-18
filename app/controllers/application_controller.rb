class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :update_permitted_parameters, if: :devise_controller?
  # after_action :verify_authorized, unless: :devise_controller?
  
  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  
  
  
  private
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:id, :first_name, :last_name, :email, :role, :company_id, :password, :password_confirmation, :can_edit) }
  end
  
  def update_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:id, :first_name, :last_name, :email, :role, :can_edit, :company_id, :password, :password_confirmation, :current_password) }
  end
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
  
  
  
end
