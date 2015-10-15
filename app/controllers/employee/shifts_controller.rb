class Employee::ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :set_employee

  # GET /shifts
  # GET /shifts.json
  def index
    
    @shifts = @employee.shifts
    
  end


  def show
    @job = @employee.current_job
  end

  # GET /shifts/new
  def new
      @job = @employee.current_job
      @shift = @employee.shifts.new
  end


  # GET /shifts/1/edit
  def edit
    @job = @shift.job

  end

  def create
    @current_job = @employee.current_job

    @shift = @job.shifts.new(job: @current_job, 
                            employee: @employee,
                            time_in: Time.current,
                            earnings: 0.00,
                            week: Date.today.cweek,
                            state: "Clocked In")


    respond_to do |format|
      if @shift.save
        format.html { redirect_to shifts_path(@shift), notice: 'Shift was successfully created.' }
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
                    out_ip: @current_user.current_sign_in_ip)
    
  end
  
  def break_start
    @shift = Shift.find(params[:id])
      @shift.breaks ||= []
      @shift.break_out ||= []
      @shift.breaks << Time.current
      @shift.break_out << Time.current
      @shift.state = 'On Break'
      @shift.save
    skip_authorization
  end
  def break_end
    @shift = Shift.find(params[:id])
    if @shift.on_break?
      @shift.breaks ||= []
      @shift.break_in ||= []
      @shift.breaks << Time.current
      @shift.break_in << Time.current
      @shift.state = 'Clocked In'
      @shift.save
    end
    skip_authorization
  end
    


  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
    @job = @shift.job

    respond_to do |format|
      if @shift.update(shift_params)
        format.html { redirect_to @shift, notice: 'Shift was successfully updated.' }
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

    @shift.destroy
    respond_to do |format|
      format.html { redirect_to employee_path(@employee), notice: 'Shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      @shift = Shift.find(params[:id])
    end
    
    def set_employee
      @current_user = current_user if user_signed_in?
      @employee = @current_user.employee
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:time_in, :time_out, :employee_id, :job_id)
    end
end
