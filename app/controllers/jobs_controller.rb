# == Schema Information
#
# Table name: jobs
#
#  id               :integer          not null, primary key
#  employee_id      :integer
#  order_id         :integer
#  title            :string
#  description      :string
#  start_date       :date
#  pay_rate         :decimal(, )
#  end_date         :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active           :boolean
#  deleted_at       :datetime
#  recruiter_id     :integer
#  timesheets_count :integer
#  settings         :hstore
#  pay_types        :text             is an Array
#  vacation         :hstore
#  state            :string           default("Pending Approval")
#
# Indexes
#
#  index_jobs_on_deleted_at    (deleted_at)
#  index_jobs_on_pay_types     (pay_types)
#  index_jobs_on_recruiter_id  (recruiter_id)
#

class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_user!
  # before_action :set_order

  # GET /jobs
  # GET /jobs.json
  def index
    if admin_signed_in? 
      @admin = current_admin
      @company = @admin.company
      @jobs = @company.jobs.order(title: :asc)
    #   # @timesheets = @company.timesheets.order(updated_at: :desc)
    #   # authorize @timesheets
    # elsif user_signed_in? && current_user.not_an_employee?
    #   @current_user = current_user if current_user.present?
    #   @company = @current_user.company
    #   @jobs = @company.jobs.order(title: :asc)
    #   # authorize @timesheets
      elsif user_signed_in? && current_user.employee?
      @current_user = current_user if current_user.present?
      @employee = @current_user.employee if @current_user.employee.present?
      @company = @current_user.company
      @jobs = @employee.jobs.order(title: :asc) if @employee.jobs.any?
      # authorize @timesheets
    end
    
    # @company = current_user.company if current_user.present?
    # @jobs = @company.jobs.active.with_employee
    # authorize @jobs
  end
  
  def archived
    @company = current_user.company if current_user.present?
    @archived_jobs = @company.jobs.inactive.with_employee
    @active_jobs = Job.active.with_employee
    # authorize @active_jobs
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    # authorize @job
    @employee = @job.employee
    @company = @job.company
    @order = @job.order
    @current_timesheet = @job.current_timesheet
    @company = @job.order.company
    @current_shift = @job.shifts.clocked_in.last if @job.on_shift?
    @all_timesheets = @job.timesheets
    @timesheets = @job.timesheets
    @last_week_timesheets =  @job.timesheets.last_week
    
  end

  # GET /jobs/new
  def new
    # if admin_signed_in? 
    #   @current_admin = current_admin
    #   @company = @current_admin.company

    #   @job = @order.jobs.new
      
    # elsif user_signed_in? && current_user.not_an_employee?
    #   @current_user = current_user
    #   @company = @current_user.company
      

    # end
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      @job = @order.jobs.new
      # @employee = @job.build_employee
      # authorize @job
    else
    
      @job = Job.new
      # authorize @job
      # @employee = @job.build_employee
    end
    # @company = Company.find(params[:company_id])

  end

  # GET /jobs/1/edit
  def edit
    @company = @job.company
    @employees = @company.employees.unassigned
    @order = @job.order
    @employee = @job.employee
    # authorize @job
  end

  # POST /jobs
  # POST /jobs.json
  def create
   
    if params[:order_id]
      @order = Order.find(params[:order_id])
      @company = @order.company
      # @employee = Employee.create(employee_params)
      @job = @order.jobs.new(job_params)
      # authorize @job
      # @job.order = @order
      # @employee = @job.create_employee(employee_params)
    else
      # @employee = Employee.create(employee_params)
      @job = Job.new(job_params)
      # authorize @job
    end
    
    respond_to do |format|
      if @job.save
        format.html { redirect_to job_path(@job, anchor: "job_#{@job.id}"), notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    # authorize @job
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    authorize @job
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.includes(:employee).find(params[:id])
      @employee = @job.employee
    end
    
    def set_order
      # @company = Company.find(params[:company_id])
      # @order = Order.find(params[:order_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:order, :recruiter_id, :title, :active, :description, :start_date, :pay_rate, :end_date, :order_id, :employee_id,
                            employee_attributes: [:id, :first_name, :last_name, :email, :ssn, :_destroy])
    end
    def employee_params
      params.require(:employee).permit(:first_name, :last_name, :email, :ssn, :phone_number)
    end
end
