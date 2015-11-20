class Admin::EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  
  before_action :authenticate_admin!
  layout 'admin_layout'



  def index
    @admin = @current_admin
    @employees = Employee.all
    # @employees = Employee.includes(:user).assigned
    gon.employees = @employees
    skip_authorization
    @import = Employee::Import.new
    respond_to do |format|
      format.html
      format.csv { send_data @employees.to_csv, filename: "employees-export-#{Time.current}-inclustaff.csv" }
  	end 
    # WAS TRYING TO USE ELASTICSEARCH (SERCHKICK GEM) ###############
    # query = params[:q].presence || "*"
    # @employees = Employee.search query, operator: "or", suggest: true, misspellings: {edit_distance: 2}
  end
  def import
      @import  = Employee::Import.new(employee_import_params)
      
      if @import.save
          redirect_to admin_employees_path, notice: "Imported #{@import_count} employees."
      else
          @employees = Employee.assigned
          render action: :index, notice: "There were errors with your CSV file."
      end
      skip_authorization
        
  end
  


  def show
    @work_histories = @employee.work_histories if @employee.work_histories.any?
    @user = @employee.user
    @shifts = @employee.shifts if @employee.shifts.any?
    @skills = @employee.skills
    @skill = @employee.skills.new
    @timesheets = @employee.timesheets if @employee.timesheets.any?
    @applications = @user.events.applications
    @events = Event.employee_events(@user.id)
   
    
    @current_job = @employee.current_job if @employee.current_job.present?
    @past_jobs = @employee.jobs.inactive if @employee.jobs.any?
   
    gon.skills = @skills
    
    authorize @employee
  end

  # GET /employees/new
  def new
    @employee = Employee.new
    @employee.build_user
    authorize @employee
  end


  def edit
    @employee.skills
    # @employee.resumes.new

  end


  def create
    @employee = Employee.new(employee_params)
    @employee.build_user
    authorize @employee

    respond_to do |format|
      if @employee.save
        format.html { redirect_to admin_employee_path(@employee), notice: 'Employee was successfully created.' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end


  def update

    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to admin_employee_path(@employee), notice: 'Employee was successfully updated.' }
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
    def employee_import_params
        params.require(:employee_import).permit(:file)
    end
    def pundit_user
      current_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.includes(:user).find(params[:id])
      authorize @employee
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_params
      params.require(:employee).permit(:first_name, :last_name, :email, :ssn, :phone_number, :user_id, :resume, :dns, :tag_list, :skill_list,
          :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :desired_job_type, :desired_shift, 
          jobs_attributes: [:title, :pay_rate, :start_date, :order_id, :id], skills_attributes: [:id, :skillable_id, :skillable_type, :name, :required, :_destroy],
          user_attributes: [:id, :email, :role, :password, :password_confirmation, :first_name, :last_name, :company_id, :current_password, :address, :city, :state, :zipcode],
          work_histories_attributes: [:id, :name, :employee_id, :employer_name, :start_date, :end_date, :title, :description, :current, :may_contact,
          :supervisor, :phone_number, :pay])
    end
end
