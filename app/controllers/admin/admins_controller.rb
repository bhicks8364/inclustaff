class Admin::AdminsController < ApplicationController
  before_filter :authenticate_admin!
  layout 'admin_layout'

  def index
    @admins = Admin.all.order(last_name: :asc)
    authorize(@admins)
    # @admins = @current_agency.agency_admins.order(role: :asc)
    # @admins = @company.admins.order(last_name: :asc) if @company.present?
    # @admins = @agency.admins.order(last_name: :asc) if @agency.present?
    
  end

  def new
    @admin = Admin.new
    authorize(@admin)
  end

  def create
    @admin = Admin.invite! admin_params.merge(agency_id: @current_agency.id)
    skip_authorization
    if @admin.persisted?
      redirect_to admin_admins_path, notice: 'You just added ' + "#{@admin.name}" + " as a #{@admin.role}. They will receive an email with further instructions."
    else
      redirect_to admin_admins_path, notice: 'Unable to add admin'
    end
    
  end

  def follow
    @admin = Admin.find(params[:id])
    authorize(@admin)
    @event = current_admin.events.create(action: "followed", eventable: @admin)
    if @event.save
      redirect_to admin_admins_path, notice: 'You are now following ' + "#{@admin.name}"
    else
      redirect_to admin_admins_path, notice: 'Unable to follow ' + "#{@admin.name}"
    end
    
  end


  def edit
    @admin = Admin.find(params[:id])
    authorize(@admin)
    
  end
  def update
    @admin = Admin.find(params[:id])
    authorize(@admin)
    
    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to admin_admin_path(@admin), notice: 'Admin info was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin }
      else
        format.html { render :edit }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @admin = Admin.find(params[:id])
    authorize(@admin)
    @events = @admin.events
    @orders = @admin.job_orders 
    @open_agency_orders = @current_agency.orders.needs_attention
    # @employees = @current_agency.employees.assigned
    # @candidates = Employee.unassigned
    # @orders = @current_agency.orders if @admin.owner? || @admin.payroll?
    # @recruiter_jobs = @admin.recruiter_jobs if @admin.recruiter?

    @jobs = @admin.jobs.includes(:employee)
    @timesheets = @admin.timesheets 
  end

  private
    
  def admin_params
    params.require(:admin).permit(:first_name, :last_name, :email, :username, :role, :company_id, :agency_id, :password, :password_confirmation)
  end
end
