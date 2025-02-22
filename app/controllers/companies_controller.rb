# == Schema Information
#
# Table name: companies
#
#  id            :integer          not null, primary key
#  name          :string
#  address       :string
#  state         :string
#  zipcode       :string
#  contact_name  :string
#  contact_email :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  city          :string
#  balance       :decimal(, )
#  phone_number  :string
#  user_id       :integer
#  agency_id     :integer
#  admin_id      :integer
#  preferences   :hstore           default({})
#
# Indexes
#
#  index_companies_on_admin_id   (admin_id)
#  index_companies_on_agency_id  (agency_id)
#  index_companies_on_user_id    (user_id)
#

class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all
    authorize @companies
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @current_admin = current_admin
    @jobs = @company.jobs.active.includes(:employee)
    @clocked_in = @jobs.on_shift
    @clocked_out =  @jobs.off_shift.distinct
    # authorize @company
    @orders = @company.orders
    # @all_timesheets = @company.timesheets.order(updated_at: :desc) if @company.timesheets.any?
    @timesheets = @company.timesheets.order(updated_at: :desc) 
    @last_week_timesheets = @timesheets.last_week.order(updated_at: :desc)

    @all_users = @company.admins
    @employees = @company.employees
    @active_employees = @employees.with_active_jobs
    # @clocked_in = @company.jobs.on_shift.includes(:employee) if @company.jobs.any?

    @with_active_jobs = @orders.with_active_jobs
    
    @today = @company.shifts.today.order(updated_at: :desc)
    @yesterday = @company.shifts.yesterday
    # @today = @company.shifts.in_today.order(time_in: :desc)
    # @yesterday = @company.shifts.in_yesterday.order(time_in: :desc)
  end

  # GET /companies/new
  def new
    @company = Company.new
    authorize @company
  end

  # GET /companies/1/edit
  def edit
    # authorize @company
  end

  # POST /companies
  # POST /companies.json
  def create
    
    @company = Company.new(company_params)
    authorize @company
    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
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
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
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
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def pundit_user
    current_admin
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.includes(:orders, :jobs).find(params[:id])
      authorize @company
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :address, :city, :state, :zipcode, :contact_name, :contact_email)
    end
end
