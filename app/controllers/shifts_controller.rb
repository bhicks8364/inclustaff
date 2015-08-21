class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_user!
  # before_action :set_employee, only: [:index, :show, :edit, :update, :destroy]

  # GET /shifts
  # GET /shifts.json
  def index
    if params[:employee_id]
      @employee = Employee.find(params[:employee_id])
      @job = @employee.current_job
      @company = @job.company if @job
      @current_shifts = @job.shifts if @job
      @shifts = @employee.shifts.order(time_in: :desc)
      # authorize @shifts
    elsif params[:job_id]
      @job = Job.find(params[:job_id])
      @employee = @job.employee
      @company = @job.company
      @shifts = @job.shifts.order(time_in: :desc)
      # authorize @shifts
    end

  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
    # @employee = Employee.find(params[:employee_id])
      @job = Job.find(params[:job_id])
      @employee = @shift.employee
      @company = @job.company
      # authorize @shift
  end

  # GET /shifts/new
  def new
    if admin_signed_in? 
      @admin = current_admin
      @job = Job.find(params[:job_id])
      # @company = @job.company
      @employee = @job.employee
      @shift = @job.shifts.new

      # authorize @timesheets
    elsif user_signed_in? && current_user.employee?
      @current_user = current_user if current_user.present?
      @job = Job.find(params[:job_id])
      # @company = @job.company
      @employee = @job.employee
      @shift = @job.shifts.new
    end


    # authorize @shift
    # @shift = Shift.new
  end

  # GET /shifts/1/edit
  def edit
    @job = Job.find(params[:job_id])
    @employee = @job.employee
    # authorize @shift
  end

  # POST /shifts
  # POST /shifts.json
  def create
     
    @job = Job.find(params[:job_id])

    @shift = @job.shifts.new(shift_params)
    @employee = @job.employee
    # authorize @shift


    respond_to do |format|
      if @shift.save
        format.html { redirect_to job_shifts_path(@job), notice: 'Shift was successfully created.' }
        format.json { render :show, status: :created, location: @shift }
      else
        format.html { render :new }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def clock_out
    sleep 2
    
    @shift = Shift.find(params[:id])
    @shift.update(time_out: Time.current,
                    state: "clocked_out",
                    out_ip: @shift.employee.user.current_sign_in_ip)
  end


  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
    # authorize @shift
    @job = Job.find(params[:job_id])
    respond_to do |format|
      if @shift.update(shift_params)
        format.html { redirect_to [@job, @shift], notice: 'Shift was successfully updated.' }
        format.json { render :show, status: :ok, location: @shift }
      else
        format.html { render :edit }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
     
    @job = Job.find(params[:job_id])
    authorize @shift
    @shift.destroy
    respond_to do |format|
      format.html { redirect_to job_shifts_path(@job), notice: 'Shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      @shift = Shift.find(params[:id])
    end
    
    def set_employee
      @employee = Employee.find(params[:employee_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:time_in, :time_out, :employee_id, :job_id)
    end
end
