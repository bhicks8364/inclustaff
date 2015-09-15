class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_admin!
  layout 'admin_layout'

  

  # GET /orders
  # GET /orders.json
  def index
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @orders = @company.orders
      
    else
      @admin = current_admin
      
      if @admin.agency?
      
        @agency = @admin.agency
      elsif @admin.company?
        @company = @admin.company
      end
      
      @orders = @company.orders.active.order(created_at: :desc) if @company.present?
      @orders = @agency.orders.active.order(created_at: :desc) if @agency.present?

    end
    
    
    authorize @orders

  end
  
  def all

    @admin = current_admin
    if @admin.agency?
      @agency = @admin.agency
    elsif @admin.company?
      @company = @admin.company
    end
    
      @orders = @company.orders.order(created_at: :desc) if @company.present?
      @orders = @agency.orders.order(created_at: :desc) if @agency.present?
      authorize @orders
    
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @company = @order.company
    @inactivejobs = @order.jobs.inactive
    @active_jobs = @order.jobs.active
    @jobs = @order.jobs.active.includes(:timesheets, :shifts)
    @timesheets = @order.timesheets
    @current_timesheets = @order.current_timesheets
    authorize @order
  end
    

  # GET /orders/new
  def new
    @admin = current_admin
    if @admin.agency?
      @agency = @admin.agency
      @account_managers = @agency.account_managers if @agency.present?
     
      @company = Company.find(params[:company_id]) if params[:company_id].present?

      @order = @company.orders.new if @company.present?
      @order = @agency.orders.new if @agency.present?
      authorize @order
    elsif @admin.company?
      @company = @admin.company
      @order = @company.orders.new
      @order.skills.new
      authorize @order
    end

    

  end

  # GET /orders/1/edit
  def edit
    @admin = current_admin
    @order = Order.find(params[:id])
    authorize @order
    @company = @order.company
    @account_managers = @company.account_managers if @company.account_managers.any?
    @account_managers = @admin.agency.admins.account_managers if @admin.agency?
    @order.skills
    
  end

  # POST /orders
  # POST /orders.json
  def create

      if params[:company_id]
        @company = Company.find(params[:company_id])
        @order = @company.orders.new(order_params)
      else
        @admin = current_admin
        @agency = @admin.agency
        @order = @agency.orders.new(order_params)
      end
      
      authorize @order





    respond_to do |format|
      if @order.save 
        format.html { redirect_to admin_company_order_path(@order.company, @order), notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    authorize @order
    @company = @order.company

    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to admin_company_order_path(@company, @order), notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @company = @order.company
    authorize @order
    @order.destroy

    respond_to do |format|
      format.html { redirect_to admin_company_orders_path(@company), notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def pundit_user
      current_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_order

      @order = Order.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :company_id, :agency_id, :account_manager_id, :manager_id, :mark_up, :title, :pay_range, :notes, :number_needed, :needed_by, :urgent, :active, :dt_req, :bg_check, :stwb, :heavy_lifting, :shift, :est_duration, 
      jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active], skills_attributes: [:id, :skillable_type, :skillable_id, :name, :required, :_destroy])
    end
end
