class Company::CompanysController < ApplicationController
  before_filter :authenticate_company_admin!
  layout 'company_admin_layout'

  def index
    @company_admins = Company.all.order(last_name: :asc)
    authorize(@company_admins)
    # @company_admins = @current_agency.agency_company_admins.order(role: :asc)
    # @company_admins = @company.company_admins.order(last_name: :asc) if @company.present?
    # @company_admins = @agency.company_admins.order(last_name: :asc) if @agency.present?
    
  end

  def new
    @company_admin = Company.new
    authorize(@company_admin)
  end

  def create
    @company_admin = Company.invite! company_admin_params.merge(agency_id: @current_agency.id)
    skip_authorization
    if @company_admin.persisted?
      redirect_to company_admin_company_admins_path, notice: 'You just added ' + "#{@company_admin.name}" + " as a #{@company_admin.role}. They will receive an email with further instructions."
    else
      redirect_to company_admin_company_admins_path, notice: 'Unable to add company_admin'
    end
    
  end

  def follow
    @company_admin = Company.find(params[:id])
    authorize(@company_admin)
    @event = current_company_admin.events.create(action: "followed", eventable: @company_admin)
    if @event.save
      redirect_to company_admin_company_admins_path, notice: 'You are now following ' + "#{@company_admin.name}"
    else
      redirect_to company_admin_company_admins_path, notice: 'Unable to follow ' + "#{@company_admin.name}"
    end
    
  end


  def edit
    @company_admin = Company.find(params[:id])
    authorize(@company_admin)
    
  end
  def update
    @company_admin = Company.find(params[:id])
    authorize(@company_admin)
    
    respond_to do |format|
      if @company_admin.update(company_admin_params)
        format.html { redirect_to company_admin_company_admin_path(@company_admin), notice: 'Company info was successfully updated.' }
        format.json { render :show, status: :ok, location: @company_admin }
      else
        format.html { render :edit }
        format.json { render json: @company_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @company_admin = Company.find(params[:id])
    authorize(@company_admin)
    @events = @company_admin.events
    @orders = @company_admin.job_orders 
    @open_agency_orders = @current_agency.orders.needs_attention
    # @employees = @current_agency.employees.assigned
    # @candidates = Employee.unassigned
    # @orders = @current_agency.orders if @company_admin.owner? || @company_admin.payroll?
    # @recruiter_jobs = @company_admin.recruiter_jobs if @company_admin.recruiter?

    @jobs = @company_admin.jobs.includes(:employee)
    @timesheets = @company_admin.timesheets 
  end

  private
    
  def company_admin_params
    params.require(:company_admin).permit(:first_name, :last_name, :email, :username, :role, :company_id, :agency_id, :password, :password_confirmation)
  end
end
