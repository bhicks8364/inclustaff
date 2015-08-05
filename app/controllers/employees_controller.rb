class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  
  # before_action :authenticate_user!

  # GET /employees
  # GET /employees.json
  def index
    @company = current_user.company if current_user.present?
    @employees = @company.employees
    authorize @employees
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
    @current_user = current_user if user_signed_in?
    @job = @employee.current_job if @employee.current_job != nil
    @current_company = @employee.company
    @company = @employee.company
    @shifts = @employee.shifts
    authorize @employee
  end

  # GET /employees/new
  def new
    @companies = Company.all
    @employee = Employee.new
    # @employee.jobs.build
    @employee.build_user
    authorize @employee
  end

  # GET /employees/1/edit
  def edit
    authorize @employee
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(employee_params)
    
    authorize @employee
    # @employee.jobs.new

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
    @employee.update(employee_params)
    authorize @employee
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
    authorize @employee
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
          user_attributes: [:id, :email, :role, :password, :password_confirmation, :first_name, :last_name, :company_id])
    end
end
