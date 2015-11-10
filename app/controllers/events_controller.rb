class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  layout :determine_layout
  # GET /events
  # GET /events.json
  def index
    Chronic.time_class = Time.zone
    @start_time = Chronic.parse(params[:date1])
    @end_time = Chronic.parse(params[:date2])
    if @start_time.present? && @end_time.present?
      @events = Event.occurring_between(@start_time, @end_time).order(created_at: :desc).distinct
    elsif @start_time.present?
      @events = Event.happened_after(@start_time).order(created_at: :desc).distinct
    elsif @end_time.present?
      @events = Event.happened_before(@end_time).order(created_at: :desc).distinct
    else
      @events = Event.order(created_at: :desc)
    end
    # @q = Event.includes(:eventable).ransack(params[:q]) 
    # if params[:q].present?
    #   @events = @q.result(distinct: true).paginate(page: params[:page], per_page: 5)
    # else
    # @events = Event.none
    # end
    
   
    skip_authorization
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @order = Order.find(@event.eventable_id) if @event.application?
    @timesheet = Timesheet.find(@event.eventable_id) if @event.timesheet?
    @company = @order.company if @order.present?
    @employee = @event.user.employee if @event.application?
    @job = @order.jobs.new if @order.present?
  end

  # GET /events/new
  def new
    @event = Event.new
    skip_authorization
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    skip_authorization
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:admin_id, :agency_id, :company_admin_id, :action, :eventable_id, :eventable_type)
    end
    
    private
      def determine_layout
        current_admin ? "admin_layout" : "application"
      end
end
