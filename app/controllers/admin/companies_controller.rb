class Admin::CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!
  layout 'admin_layout'
  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all
    @top_billing = Company.ordered_by_current_bill

    @import = Company::Import.new
    # authorize @companies
    skip_authorization
    respond_to do |format|
      format.html
      format.csv { send_data @companies.to_csv, filename: "companies-export-#{Time.now}-inclustaff.csv" }
  	end

  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    # @order = @company.orders.new
    authorize @company
    @orders = @company.orders
    @jobs = @company.jobs

    @timesheets = @company.timesheets.order(updated_at: :desc).distinct
    @last_week_timesheets = @timesheets.last_week.order(updated_at: :desc).distinct

    @all_users = @company.admins
    @employees = @company.employees
    @active_employees = @employees.with_active_jobs
    # @clocked_in = @company.jobs.on_shift.includes(:employee) if @company.jobs.any?

    @with_active_jobs = @orders.with_active_jobs

    @today = @company.shifts.today.order(updated_at: :desc)
    @yesterday = @company.shifts.yesterday
    # @today = @company.shifts.in_today.order(time_in: :desc)
    # @yesterday = @company.shifts.in_yesterday.order(time_in: :desc)
    @pdf_type = params[:pdf_type]
    respond_to do |format|
      format.html
      if @pdf_type =="info"
      format.pdf {
                    send_data CompanyPdf.new(@company, @signed_in, @current_agency, view_context, @pdf_type).render,
                    filename: "#{@current_agency.name}-#{@pdf_type}-#{Time.current}.pdf",
                    type: "application/pdf",
                    disposition: :inline
                }
      elsif @pdf_type == "agreement"
        format.pdf {
                    send_data CompanyAgreementPdf.new(@company, @signed_in, @current_agency, view_context, @pdf_type).render,
                    filename: "#{@current_agency.name}-#{@pdf_type}-#{Time.current}.pdf",
                    type: "application/pdf",
                    disposition: :inline
                }
      end
    end
  end

  # GET /companies/new
  def new
    if @current_agency.admins.account_managers.count == 0
      redirect_to new_admin_admin_path, notice: "Please add an account manager before adding a company."
    end
    @company = @current_agency.companies.new
    authorize @company
  end
  def import
      @companies = Company.all
      @import  = Company::Import.new(company_import_params)

      if @import.save
          redirect_to admin_companies_path, notice: "Imported #{@import_count} companines."
      else
          render action: :index, notice: "There were errors with your CSV file."
      end
      skip_authorization

  end

  # GET /companies/1/edit
  def edit
    # authorize @company
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = @current_agency.companies.new(company_params)
    authorize @company

    respond_to do |format|
      if @company.save
        current_admin.events.create(action: "created", eventable: @company)
        format.html { redirect_to admin_company_path(@company), notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    # authorize @company
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to admin_company_path(@company), notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy

    @company.destroy
    authorize @company
    respond_to do |format|
      format.html { redirect_to admin_companies_path, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def company_import_params
        params.require(:company_import).permit(:file, :agency_id)
    end

    def pundit_user
      current_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :address, :city, :state, :zipcode, :contact_name, :contact_email, :current_account_manager, :admin_id, :agency_id, :phone_number,
      orders_attributes: [:id, :company_id, :agency_id, :account_manager_id, :manager_id, :mark_up, :title,
      :notes, :number_needed, :needed_by, :urgent, :active, :dt_req, :bg_check, :stwb, :heavy_lifting, :shift, :est_duration])
    end
end
