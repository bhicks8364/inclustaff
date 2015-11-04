class Company::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_company_admin!

  

  # GET /orders
  # GET /orders.json
  def index
    @admin = current_company_admin
      @company = @admin.company
      @orders = @company.orders.order(title: :asc)
   
    
    

    
  end
  
  def all
    if admin_signed_in? 
      @admin = current_admin
      @company = @admin.company
      @timesheets = @company.timesheets.order(updated_at: :desc)
      @orders = @company.orders
      @with_active_jobs = @orders.with_active_jobs
    # authorize @orders
    elsif user_signed_in? && current_user.not_an_employee?
      @current_user = current_user if current_user.present?
      @company = @current_user.company
      @orders = @company.orders
      @with_active_jobs = @orders.with_active_jobs
      @timesheets = @company.timesheets.order(updated_at: :desc)
    # authorize @orders
    end
    # @orders = Order.all
    # authorize @orders
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @company = @order.company
    @inactivejobs = @order.jobs.inactive
    @active_jobs = @order.jobs.active
    @jobs = @order.jobs.active.includes(:shifts)
    # authorize @order
  end
    

  # GET /orders/new
  def new
    if company_admin_signed_in? 
      @admin = current_company_admin
      @company = @admin.company
      @order = @company.orders.new
    end


  end

  # GET /orders/1/edit
  def edit

      @order = Order.find(params[:id])


  end

  # POST /orders
  # POST /orders.json
  def create
    @admin = current_company_admin
    @company = @admin.company
    @order = @company.orders.new(order_params)
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

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    @company = Order.find(params[:id])
    skip_authorization
    # authorize @order
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to company_order_path(@company, @order), notice: 'Order was successfully updated.' }
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
    authorize @order
    @order.destroy

    respond_to do |format|
      format.html { redirect_to company_orders_path(@company), notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
    def pundit_user
      current_company_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_order

      @order = Order.find(params[:id])
         skip_authorization
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :company_id, :agency_id, :account_manager_id, :manager_id, :mark_up, :title, :pay_range, :notes, :number_needed, :needed_by, :urgent, :active, :dt_req, :bg_check, :stwb, :heavy_lifting, :shift, :est_duration, :tag_list, 
      jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active], skills_attributes: [:id, :skillable_type, :skillable_id, :name, :required, :_destroy])
    end
end
