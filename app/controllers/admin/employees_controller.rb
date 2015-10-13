class Admin::EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  
  before_action :authenticate_admin!
  layout 'admin_layout'
  # GET /employees
  # GET /employees.json
  def index
    @admin = current_admin
    # if @admin.agency?
    #   @agency = @admin.agency
    #   @employees = Employee.all if @agency.present?
    # elsif @admin.company?
    #   @company = @admin.company
    #   @employees = @company.employees if @company.present?
    # end
    
    query = params[:q].presence || "*"
    # @employees = Employee.search query, operator: "or", suggest: true, misspellings: {edit_distance: 2}
    
    @employees = @current.employees
      
      

      gon.employees = @employees
      skip_authorization
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
    @work_histories = @employee.work_histories
    
    
    
    @user = @employee.user
    @shifts = @employee.shifts.order(time_in: :desc).limit(5) if @employee.shifts.any?
    @skills = @employee.skills
    @skill = @employee.skills.new
    @applications = @user.events.applications
    @events = Event.employee_events(@user.id)
   
    gon.skills = @skills
    # @company = @employee.company
    @job = @employee.jobs.new
    @current_job = @employee.current_job if @employee.current_job.present?
    @jobs = @employee.jobs
    @timesheets = @employee.timesheets.order(created_at: :desc).limit(2) if @employee.timesheets.any?

    
    authorize @employee
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
    authorize @employee
  end

  # GET /employees/1/edit
  def edit
    @employee.skills
    @employee.resumes.new

  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(employee_params)
    @employee
    authorize @employee
    

      # @admin = current_admin
      # @company = @admin.company
      # @employees = @company.employees.order(last_name: :asc)
      # @employee = @company.employees.new(employee_params)


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

  # PATCH/PUT /employees/1
  # PATCH/PUT /employees/1.json
  def update
    # @company = @employee.current_job.company
    
    
    # authorize @employee
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
      params.require(:employee).permit(:first_name, :last_name, :email, :ssn, :phone_number, :user_id, :resume,
          jobs_attributes: [:title, :pay_rate, :start_date, :order_id, :id], skills_attributes: [:id, :skillable_id, :skillable_type, :name, :required, :_destroy],
          user_attributes: [:id, :email, :role, :password, :password_confirmation, :first_name, :last_name, :company_id, :current_password, :address, :city, :state, :zipcode],
          work_histories_attributes: [:id, :name, :employee_id, :employer_name, :start_date, :end_date, :title, :description, :current, :may_contact,
          :supervisor, :phone_number, :pay])
    end
end
