class Admin::AdminsController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin_layout'

  def index
    @admins = Admin.all.order(last_name: :asc)
    # @admins = @current_agency.agency_admins.order(role: :asc)
    # @admins = @company.admins.order(last_name: :asc) if @company.present?
    # @admins = @agency.admins.order(last_name: :asc) if @agency.present?
    skip_authorization
  end

  def new
    @admin = Admin.new
    skip_authorization
  end

  def create
    @admin = Admin.invite! admin_params.merge(agency_id: @current_agency.id)
    if @admin.persisted?
      redirect_to admin_admins_path, notice: 'You just added ' + "#{@admin.name}" + " as a #{@admin.role}"
    else
      redirect_to admin_admins_path, notice: 'Unable to add admin'
    end
    skip_authorization
  end

  def follow
    @admin = Admin.find(params[:id])
    @event = current_admin.events.create(action: "followed", eventable: @admin)
    if @event.save
      redirect_to admin_admins_path, notice: 'You are now following ' + "#{@admin.name}"
    else
      redirect_to admin_admins_path, notice: 'Unable to follow ' + "#{@admin.name}"
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

    @jobs = Job.includes(:timesheets) if @admin.owner? || @admin.payroll? || @admin.account_manager?
    @timesheets = @current_agency.timesheets if @admin.owner? || @admin.payroll?

    skip_authorization
  end

  private

  def admin_params
    params.require(:admin).permit(:first_name, :last_name, :email, :username, :role, :company_id, :agency_id, :password, :password_confirmation)
  end
end
