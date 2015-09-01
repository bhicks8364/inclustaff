class Admin::ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!
  before_action :set_admin

  def index
    @shifts = @current_admin.shifts.current_week.order(time_in: :desc)
    gon.shifts = @shifts
  end
  
  def show
    @employee = @shift.employee
    @job = @shift.job
    gon.shift = @shift
  end

  def new
    @company = @current_admin.company
    @jobs = @company.jobs.off_shift.distinct
    # @jobs = @company.jobs.off_shift.distinct
    # @orders = @company.orders.off_shift.distinct
    @shift = Shift.new
  end


  # GET /shifts/1/edit
  def edit
    @job = @shift.job
    @employee = @shift.employee
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @shift = Shift.new(shift_params)

    respond_to do |format|
      if @shift.save
        format.html { redirect_to dashboard_path, anchor: "job_#{@shift.job_id}", notice: 'Sucessfully clocked in.' }
        format.json { render :show, status: :created, location: @shift }
      else
        format.html { render :new }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def clock_out
    @shift = Shift.find(params[:id])
    if @shift.clocked_in?
      @shift.out_ip = current_admin.last_name + "-admin"
      @shift.clock_out!
    elsif @shift.clocked_out?
      @shift.clock_in!
    end
    respond_to do |format|
      if @shift.save
        time_out = @shift.time_out.nil? ? @shift.state : @shift.time_out.strftime("%l:%M%P")
        
        format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, 
                    state: @shift.state, time_out: time_out,
                    out_ip: @shift.out_ip, time_in: @shift.time_in.strftime("%l:%M%P"),
                    in_ip: @shift.in_ip } }
  
      else

        format.html { render :edit }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
        
        
      end
    end
  end
  
  
  def clock_out_all
    @shifts = @current_admin.shifts.clocked_in
    @shifts.each { |shift| shift.update(time_out: Time.current,
                      state: "Clocked Out",
                      out_ip: current_admin.last_name + "-admin")}
    respond_to do |format|
        format.js 
    end
  end


  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
    @job = @shift.job
    @employee = @shift.employee
    @shift.update(shift_params)
   

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
      format.html { redirect_to dashboard_path, notice: 'Shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift
      @shift = Shift.find(params[:id])
    end
    
    def set_admin
      @current_admin = current_admin if admin_signed_in?
      
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:time_in, :time_out, :employee_id, :job_id, :note, :break_in, :break_out, :needs_adj, :week, :state)
    end
end
