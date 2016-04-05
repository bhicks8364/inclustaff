# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  admin_id         :integer
#  action           :string
#  eventable_id     :integer
#  eventable_type   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  agency_id        :integer
#  company_admin_id :integer
#  read_at          :datetime
#
# Indexes
#
#  index_events_on_agency_id         (agency_id)
#  index_events_on_company_admin_id  (company_admin_id)
#  index_events_on_user_id           (user_id)
#

class Company::EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  layout "company_layout"
  # GET /events
  # GET /events.json
  def index
    
    Chronic.time_class = Time.zone
    @start_time = Chronic.parse(params[:date1])
    @end_time = Chronic.parse(params[:date2])
    if @start_time.present? && @end_time.present?
      @events = @current_company.events.occurring_between(@start_time, @end_time).order(created_at: :desc).distinct
    elsif @start_time.present?
      @events = @current_company.events.happened_after(@start_time).order(created_at: :desc).distinct
    elsif @end_time.present?
      @events = @current_company.events.happened_before(@end_time).order(created_at: :desc).distinct
    else
      @events = @current_company.events.all.order(created_at: :desc)
      # @events = @signed_in.events.unread
    end
    
    
    # @q = @current_company.events.includes(:eventable).ransack(params[:q]) 
    # if params[:q].present?
    #   @events = @q.result(distinct: true).paginate(page: params[:page], per_page: 5)
    # else
    # @events = @current_company.events.none
    # end
      
   
    skip_authorization
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @order = Order.find(@event.eventable_id) if @event.application?
    @timesheet = Timesheet.find(@event.eventable_id) if @event.timesheet?
    @shift = Shift.find(@event.eventable_id) if @event.eventable_type == "Shift"
    @company = @order.company if @order.present?
    @employee = @event.user.employee if @event.application?
    @job = @order.jobs.new if @order.present?
  end

  # GET /events/new
  def new
    @event = @current_company.events.new
    skip_authorization
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = @current_company.events.new(event_params)
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
  def mark_all_as_read
    skip_authorization
    @events = @current_company.events.unread
    @events.update_all(read_at: Time.zone.now)
    
    render json: {success: true}
  end
  def mark_as_read
    if @event.unread?
      @event.update(read_at: Time.current)
    else
      @event.update(read_at: nil)
    end
    @new_count = Comment.unread.count
    render json: { id: @event.id, read: @event.read?, new_count: @new_count,
                    body: @event.body, eventable: @event.eventable, state: @event.state}
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
      format.html { redirect_to(:back, notice: 'Wohohh.') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = @current_company.events.find(params[:id])
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:admin_id, :agency_id, :company_admin_id, :action, :eventable_id, :eventable_type, :read_at)
    end
    
    private
      def determine_layout
        if admin_signed_in?
          "admin_layout"
        elsif company_admin_signed_in?
          "company_layout"
        elsif user_signed_in?
          "employee"
        else
            "application"
        end
      end
end
