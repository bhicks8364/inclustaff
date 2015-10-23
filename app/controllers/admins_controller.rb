class AdminsController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin_layout'
  def index
      
      @agency_admins = @current_agency.agency_admins.order(role: :asc) if @current_agency.present?
      # @admins = @current_agency.agency_admins.order(role: :asc)
        # @admins = @company.admins.order(last_name: :asc) if @company.present?
        # @admins = @agency.admins.order(last_name: :asc) if @agency.present?
      skip_authorization
      respond_to do |format|
        format.json
        format.html

    end
  end
    
  # def new
  #   if params[:company_id].present?
  #     @company = Company.find(params[:company_id])
  #     @admin = @company.admins.new
  #   else
  #     @admin = Admin.new
  #   end
    
  # end
  # def create
  #   if params[:company_id].present?
  #     @company = Company.find(params[:company_id])
  #     @admin = @company.admins.new(admin_params)
  #   else
  #     @admin = Admin.new(admin_params)
  #   end
    
  #   if params[:password].blank?
  #     @admin.password = "password"
  #     @admin.password_confirmation = "password"
  #   end
  #   if @admin.save
  #     redirect_to admins_path, notice: 'You are just added ' + "#{@admin.name}" 
  #   else
  #     redirect_to admins_path, notice: 'Unable to add admin'
  #   end
  #   skip_authorization
  # end
  
    
    def follow
      @admin = Admin.find(params[:id])
      @event = current_admin.events.create(action: "followed", eventable: @admin)
      if @event.save
        redirect_to admins_path, notice: 'You are now following ' + "#{@admin.name}"
      else
        redirect_to admins_path, notice: 'Unable to follow ' + "#{@admin.name}"
      end
      skip_authorization
    end
    
    
    def edit
        @admin = Admin.find(params[:id])
      skip_authorization
    end
    def update
      @admin = Admin.find(params[:id])
      skip_authorization
      respond_to do |format|
        if @admin.update(admin_params)
          format.html { redirect_to @admin, notice: 'Admin info was successfully updated.' }
          format.json { render :show, status: :ok, location: @admin }
        else
          format.html { render :edit }
          format.json { render json: @admin.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def show
      @admin = Admin.find(params[:id])
      @events = @admin.events
            
      # @employees = @current_agency.employees.assigned
      @candidates = Employee.unassigned
      @open_agency_orders = @current_agency.orders.needs_attention
      @orders = @admin.account_orders if @admin.account_manager?
      @orders = @current_agency.orders if @admin.owner? || @admin.payroll?
      @recruiter_jobs = @admin.recruiter_jobs if @admin.recruiter?
      
      @jobs = @current_agency.jobs.includes(:timesheets) if @admin.owner? || @admin.payroll?
      @timesheets = @current_agency.timesheets if @admin.owner? || @admin.payroll?

        skip_authorization
    end
    
    private
    def admin_params
      params.require(:admin).permit(:first_name, :last_name, :email, :username, :role, :company_id, :agency_id, :password, :password_confirmation)
    end
    
    
    
end