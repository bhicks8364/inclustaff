class Company::ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_company_admin!
  before_action :set_company_admin
  layout "company_layout"

  def index
    @jobs = @company_admin.company.jobs.includes(:shifts).paginate(:page => params[:page], :per_page => 5).order('id DESC') if @company_admin.present?
      @shifts = @company.shifts
    # gon.shifts = @shifts
    authorize @shifts
  end

  def show
    @employee = @shift.employee
    @job = @shift.job
    @timesheet = @shift.timesheet
    @order = @job.order
    @company = @order.company
    gon.shift = @shift

  end

  def new
    @jobs = @company.jobs.off_shift.distinct
    # @jobs = @company.jobs.off_shift.distinct
    # @orders = @company.orders.off_shift.distinct
    @shift = Shift.new
    skip_authorization
  end


  # GET /shifts/1/edit
  def edit
    @job = @shift.job
    @employee = @shift.employee
  end

  #def break_start
  #@shift = Shift.find(params[:id])
  #@shift.breaks ||= []
  #@shift.break_out ||= []
  #@shift.breaks << Time.current
  #@shift.break_out << Time.current
  #@shift.state = 'On Break'
  #@shift.save
  #skip_authorization
  #end
  #def break_end
  #@shift = Shift.find(params[:id])
  #if @shift.on_break?
  #@shift.breaks ||= []
  #@shift.break_in ||= []
  #@shift.breaks << Time.current
  #@shift.break_in << Time.current
  #@shift.state = 'Clocked In'
  #@shift.save
  #end
  #skip_authorization
  #end
  ## THIS DOESNT WORK
  #def remove_breaks
  #@shift = Shift.find(params[:id])
  #@shift.update(
  #breaks:        [],
  #break_in:      [],
  #break_out:     [],
  #break_duration: 0
  #)
  #skip_authorization
  #end

  # POST /shifts
  # POST /shifts.json
  def create
    @shift = Shift.new(shift_params)
    authorize @shift

    respond_to do |format|
      if @shift.save
        format.html { redirect_to company_dashboard_path, anchor: "job_#{@shift.job_id}", notice: 'Sucessfully clocked in.' }
        format.json { render :show, status: :created, location: @shift }
      else
        format.html { render :new }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def clock_out
    @shift = Shift.find(params[:id])
    if @shift.clock_in?
    
      @shift.update(time_out: Time.current,
                    state: "Clocked Out",
                    out_ip: "#{@current_company_admin.name}", week: Date.today.beginning_of_week )

      respond_to do |format|
        if @shift.save

          @current_company_admin.events.create(action: "clocked_out", eventable: @shift, user_id: @shift.employee.user_id)


          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?,
                                       state: @shift.state, time_out: @shift.time_out.strftime("%l:%M%P"),
                                       out_ip: @shift.out_ip, time_in: @shift.time_in.strftime("%l:%M%P"),
                                       in_ip: @shift.in_ip } }

        else

          format.html { render :edit }
          format.json { render json: @shift.errors, status: :unprocessable_entity }


        end
      end
    end
  end

  def clock_in
    @shift = Shift.find(params[:id])
    @job = @shift.job
    if @shift.clocked_out?
      @shift = @job.shifts.create(time_in: Time.current, week: Date.today.cweek,
                                  state: "Clocked In",
                                  in_ip: @current_company_admin.last_name + "-company")
      respond_to do |format|
        if @shift.save
          @current_company_admin.events.create(action: "clocked_in", eventable: @shift, user_id: @shift.employee.user_id)

          format.json { render json: { id: @shift.id, clocked_in: @shift.clocked_in?, clocked_out: @shift.clocked_out?,
                                       state: @shift.state, time_in: @shift.time_in.strftime("%l:%M%P"), time_out: @shift.time_out,
                                       in_ip: @shift.in_ip } }

        else

          format.html { render :new }
          format.json { render json: @shift.errors, status: :unprocessable_entity }


        end

      end
    end
  end



  def clock_out_all
    @shifts = @company_admin.shifts.clocked_in
    @shifts.each { |shift| shift.update(time_out: Time.current,
                                        state: "Clocked Out",
                                        out_ip: @company_admin.last_name + "-admin")}
    respond_to do |format|
      format.js
    end
  end


  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
    # @job = @shift.job
    # @employee = @shift.employee
    # time = @shift.time_out || @shift.time_in
    # @shift.week = time.to_datetime

    respond_to do |format|
      if @shift.update(shift_params)
        format.html { redirect_to company_shift_path(@shift), notice: 'Shift was successfully updated.' }
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
      format.html { redirect_to root_path, notice: 'Shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def pundit_user
    current_company_admin
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_shift
    @shift = Shift.find(params[:id])
    skip_authorization
  end

  def set_company_admin
    @current_company_admin = current_company_admin

    @company = @current_company_admin.company

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shift_params
    params.require(:shift).permit(:time_in, :time_out, :paid_breaks, :pay_rate, :employee_id, :job_id, :note, :break_in, :break_out, :break_duration, :needs_adj, :week, :state).tap do |whitelisted|
      whitelisted[:breaks] = params[:shift][:breaks] if params[:shift][:breaks]
    end
  end
end
