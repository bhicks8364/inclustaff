class Company::OrdersController < ApplicationController
  before_action :authenticate_company_admin!, :set_company
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  layout "company_layout"
  def index
    @orders = @company.orders.active.order(title: :asc)
    authorize @orders
  end
  def inactive
    @orders = @company.orders.inactive.order(title: :asc)
    authorize @orders, :index?
  end
  
  def all
    @orders = @company.orders.all
    authorize @orders, :index?
  end

  def show
    @jobs = @order.jobs.includes(:shifts)
    @inactive_jobs = @jobs.inactive
    @active_jobs = @jobs.active
  end

  def new
    @order = @company.orders.new
    authorize @order
  end
  
  def edit
  end

  def create
    @order = @company.orders.new(order_params)
    @order.agency = @current_agency
    @admin.events.create(action: "submitted", eventable: @order)
    skip_authorization
    
    respond_to do |format|
      if @order.save 
        format.html { redirect_to company_order_path(@order), notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
      @order.agency = @current_agency
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to company_order_path(@order), notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy
    
    respond_to do |format|
      format.html { redirect_to company_orders_path, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
    def pundit_user
      current_company_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = @company.orders.find(params[:id])
        authorize @order
    end
    
    def set_company
      @admin = current_company_admin
      @company = @admin.company
    end

    def order_params
      params.require(:order).permit(:id, :address, :min_pay, :max_pay, :pay_frequency, :company_id, :agency_id, :account_manager_id, :manager_id, :mark_up, :title, :notes, 
      :number_needed, :needed_by, :urgent, :active, :dt_req, :bg_check, :stwb, :heavy_lifting, :shift, :est_duration, :tag_list, :aca_type,
      :education, :industry, :years_of_experience, :certifications, :requirement_1, :requirement_2, :requirement_3, :requirement_4, 
      :published_at, :published_by, :expires_at, :company_approval, :agency_approval, :mobile_time_clock_enabled,
      jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active], 
      skills_attributes: [:id, :skillable_type, :skillable_id, :name, :required, :_destroy])
    end
end
