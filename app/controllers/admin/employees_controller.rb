class Admin::EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  
  before_action :authenticate_admin!

  # GET /employees
  # GET /employees.json
  def index
      @admin = current_admin
      @company = @admin.company
      @employees = @company.employees.with_active_jobs.order(last_name: :asc)
      gon.employees = @employees
      # authorize @employees
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
    @shifts = @employee.shifts.order(time_in: :desc).limit(5) if @employee.shifts.any?

    
    @company = @employee.company
    @job = @employee.current_job if @employee.current_job.present?
    @jobs = @employee.jobs
    @timesheets = @employee.timesheets.order(created_at: :desc).limit(2)
    @last_week_timesheets = @timesheets.last_week.order(updated_at: :desc)
    @current_timesheet = @employee.current_timesheet if @employee.current_job.present?
    # @job = @employee.current_job if @employee.current_job != nil
    # @current_company = @employee.company
    # @company = @employee.company
    # @jobs = @employee.jobs.includes(:shifts)
    # # @timesheets = @employee.timesheets  if @employee.timesheets.any?
    # @all_timesheets = @employee.timesheets.order(updated_at: :desc) if @employee.timesheets.any?
    # @timesheets = @all_timesheets.this_week.order(updated_at: :desc) if @employee.timesheets.any?
    # @last_week_timesheets = @timesheets.last_week.order(updated_at: :desc) if @employee.timesheets.any?
    
    # authorize @employee
  end

  # GET /employees/new
  def new

      @admin = current_admin
      @company = @admin.company
      @employees = @company.employees.order(last_name: :asc)
      @employee = Employee.new
      @employee.build_user
    # @current_user = current_user if user_signed_in?
    # @company = @current_user.company 
    # @employee = Employee.new
    # # @employee.jobs.build
    # @employee.build_user
    # authorize @employee
  end

  # GET /employees/1/edit
  def edit
    @company = @employee.current_job.company
    @user = @employee.build_user
    
    # authorize @employee
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(employee_params)
    @employee.build_user

      @admin = current_admin
      @company = @admin.company
      # @employees = @company.employees.order(last_name: :asc)
      # @employee = @company.employees.new(employee_params)


    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employees/1
  # PATCH/PUT /employees/1.json
  def update
    @company = @employee.current_job.company
    
    @employee.update(employee_params)
    # authorize @employee
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy

    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_url, notice: 'Employee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_params
      params.require(:employee).permit(:first_name, :last_name, :email, :ssn, :phone_number, :user_id,
          jobs_attributes: [:title, :pay_rate, :start_date, :order_id, :id],
          user_attributes: [:id, :email, :role, :password, :password_confirmation, :first_name, :last_name, :company_id, :current_password, :address, :city, :state, :zipcode])
    end
end
