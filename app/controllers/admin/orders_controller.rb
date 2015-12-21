class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_admin!
  layout 'admin_layout'

  

  # GET /orders
  # GET /orders.json
  def index
    @import = Order::Import.new
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @orders = @company.orders
     
    else
      @q_orders = Order.includes(:company, :jobs).active.ransack(params[:q]) 
      @orders = @q_orders.result(distinct: true).paginate(page: params[:page], per_page: 25)
      # @orders = Order.includes(:jobs).active.order(created_at: :desc) 
    end
    if params[:tag]
      @orders = Order.needs_attention
      @orders = @orders.tagged_with(params[:tag])
    end
    authorize @orders
    
    respond_to do |format|
        format.html
        format.json
        format.csv { send_data @orders.to_csv, filename: "orders-export-#{Time.now}-inclustaff.csv" }
    end 
    
    
  end
  
  def search
    @q_orders = Order.includes(:company, :jobs).active.ransack(params[:q]) 
    @orders = @q_orders.result(distinct: true).paginate(page: params[:page], per_page: 25)
    authorize @orders, :index?
  end
  
  def show
    @company = @order.company
    @jobs = @order.jobs.includes(:timesheets, :shifts)
    @inactivejobs = @jobs.inactive
    @active_jobs = @jobs.active
    
    @timesheets = @order.timesheets
    @current_timesheets = @order.current_timesheets
    authorize @order
  end
    

  # GET /orders/new
  def new
    if params[:company_id]
    @company = Company.find(params[:company_id])
    @order = @company.orders.new
    else
      @order = Order.new
    end
    authorize @order

  end
  
  def tag_cloud
    @tags = Order.tag_counts_on(:tags)
  end

  # GET /orders/1/edit
  def edit
   
    @order = Order.find(params[:id])
    authorize @order
    @company = @order.company
    @account_managers = @company.account_managers if @company.account_managers.any?
    @account_managers = @current_agency.admins.account_managers if @current_agency.present?
    # @order.skills
    
  end

  # POST /orders
  # POST /orders.json
  def create
    @current_admin = current_admin
    

      if params[:company_id]
        
        @company = Company.find(params[:company_id])
        @order = @company.orders.new(order_params)
        @order.agency = @current_agency if @current_agency.present?
      else
        
        @account_managers = @current_agency.admins.account_managers if @current_agency.present?
        @order = @current_agency.orders.new(order_params) if @current_agency.present?
        @order.agency = @current_agency if @current_agency.present?
        
      end
      @order.account_manager = @current_admin if @current_admin.account_manager?
      authorize @order
        current_admin.events.create(action: "submitted", eventable: @order)




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
  def import
      @import  = Order::Import.new(order_import_params)
      
      if @import.save
          redirect_to admin_orders_path, notice: "Imported #{@import_count} orders."
      else
          @orders = Order.all
          render action: :index, notice: "There were errors with your CSV file."
      end
      skip_authorization
      
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

      @order = Order.includes(:skills).find(params[:id])
    end
    def order_import_params
        params.require(:order_import).permit(:file)
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :min_pay, :max_pay, :pay_frequency, :company_id, :agency_id, :account_manager_id, :manager_id, :mark_up, :title, :pay_range, :notes, :number_needed, :needed_by, :urgent, :active, :dt_req, :bg_check, :stwb, :heavy_lifting, :shift, :est_duration, :tag_list, 
      jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active], skills_attributes: [:id, :skillable_type, :skillable_id, :name, :required, :_destroy])
    end
end
