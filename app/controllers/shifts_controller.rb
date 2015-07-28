class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  # before_action :set_employee, only: [:index, :show, :edit, :update, :destroy]

  # GET /shifts
  # GET /shifts.json
  def index
    if params[:employee_id]
      @employee = Employee.find(params[:employee_id])
      @job = @employee.current_job
      @company = @job.company if @job
      

      @current_shifts = @job.shifts if @job
      @shifts = @employee.shifts
    elsif params[:job_id]
      @job = Job.find(params[:job_id])
      @employee = @job.employee
      @company = @job.company
      @shifts = @job.shifts
    end

  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
    # @employee = Employee.find(params[:employee_id])
      @job = Job.find(params[:job_id])
      @employee = @shift.employee
      @company = @job.company
  end

  # GET /shifts/new
  def new
    @job = Job.find(params[:job_id])
    @company = @job.company
    @employee = @job.employee
    @shift = @job.shifts.new
    # @shift = Shift.new
  end

  # GET /shifts/1/edit
  def edit
    @job = Job.find(params[:job_id])
    @employee = @job.employee
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @job = Job.find(params[:job_id])
    @employee = @job.employee
    @shift = @job.shifts.new(shift_params)
    @shift.employee = @employee


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
    @shift.clock_out!
      if @shift.update(shift_params)
        format.html { redirect_to job_shifts_path(@job), notice: "You're now off the clock." }
      end
  end


  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
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
