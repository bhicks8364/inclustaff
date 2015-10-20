class Users::RegistrationsController < Devise::RegistrationsController
before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]


  layout 'new_employee'
  def new
    if admin_signed_in?
      # subdomains = request.subdomains
      # @current_agency = Agency.where(subdomain: subdomains).first
      # @newly_added = Employee.newly_added.order(created_at: :desc) if @current_agency.present?
      # @at_work = @current.jobs.at_work if @current_admin.present?
      @import = User::Import.new
      # @current_agency = current_admin.agency if current_admin.agency?
      @agency_jobs = @current_agency.jobs if @current_agency.present?
      super
    else
      super
    end
  end
  def create
    @import = User::Import.new
   build_resource(sign_up_params)
  # SETS DEFAULT PASSWORD FOR USERS if left blank (for csv importing)
    if params[:password].nil?
      resource.password = "password"
      resource.password_confirmation = "password"
    end
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def sign_up(resource_name, resource)
    true

  end
  
  
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:id, :first_name, :last_name, :email, :role, :employee_id, :resume_id, 
    :password, :password_confirmation, :can_edit, :address, :city, :state, :zipcode,
    resume_attributes: [:id, :name, :employee_id, :body]) }
  end
  
  def after_sign_up_path_for(resource)
    if admin_signed_in?
     admin_employee_path(resource.employee)
    elsif signed_in == false
    
    end
  end
    
  # end
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # # The path used after sign up.
  

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
