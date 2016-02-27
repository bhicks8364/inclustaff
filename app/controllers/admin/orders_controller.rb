class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_admin!
  layout 'admin_layout'

  

  # GET /orders
  # GET /orders.json
  def index
    @q = Order.includes(:company).active.order(needed_by: :desc).ransack(params[:q]) if @current_admin.owner? || @current_admin.payroll? || @current_admin.account_manager?
    @q = Order.includes(:company).order(needed_by: :desc).ransack(params[:q]) if @current_admin.recruiter?
    @import = Order::Import.new
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @orders = @company.orders.paginate(page: params[:page], per_page: 25)
     
    else
      @q_orders = Order.includes(:company).ransack(params[:q]) 
      @orders = @q_orders.result(distinct: true).paginate(page: params[:page], per_page: 25)
      # @orders = Order.includes(:jobs).active.order(created_at: :desc) 
    end
    if params[:tag]
      @orders = Order.needs_attention
      @orders = @orders.tagged_with(params[:tag])
    end
    @hash = Gmaps4rails.build_markers(@orders) do |order, marker|
          marker.lat order.latitude
          marker.lng order.longitude
          marker.infowindow order.title_company
          marker.title order.title
        end
    gon.order = @hash
    authorize @orders
    
    respond_to do |format|
        format.html
        format.json
        format.csv { send_data @orders.to_csv, filename: "orders-export-#{Time.current}-inclustaff.csv" }
    end 
    
    
  end
  
  def inactive
    @inactive = @current_admin.job_orders.inactive
    authorize @inactive, :index?
  end
  
  def search
    @q = Order.includes(:company).active.order(needed_by: :desc).ransack(params[:q]) if @current_admin.owner? || @current_admin.payroll? || @current_admin.account_manager?
    @q = Order.includes(:company).needs_attention.order(needed_by: :desc).ransack(params[:q]) if @current_admin.recruiter?
    @q = Order.includes(:company).needs_attention.order(needed_by: :desc).ransack(params[:q]) if @q.nil?
    @orders = @q.result(distinct: true).paginate(page: params[:page], per_page: 25)
    @q.build_condition if @q.conditions.empty?
    @q.build_sort if @q.sorts.empty?
    @map_orders = @orders.any? ? @orders : @current_agency.orders.active.needs_attention.order(needed_by: :asc)
     @hash = Gmaps4rails.build_markers(@map_orders) do |order, marker|
          marker.lat order.latitude
          marker.lng order.longitude
          marker.infowindow order.title_company
          marker.title order.title
        end
    authorize @orders, :index?
  end
  
  def show
    @company = @order.company
    @jobs = @order.jobs.includes(:timesheets, :shifts)
    @inactivejobs = @jobs.inactive
    @active_jobs = @jobs.active
    @near_by = User.available.near(@order.address)
    @timesheets = @order.timesheets
    @current_timesheets = @order.current_timesheets
    authorize @order
    respond_to do |format|
      format.html 
      format.pdf do
        pdf = OrderPdf.new(@order, @current_agency, @order.min_pay, view_context)
        send_data pdf.render, filename: "#{@order.title_company}_#{Time.current}", type: "application/pdf", disposition: "inline"
      end
    end
   
  end
    

  # GET /orders/new
  def new
    if @current_agency.admins.account_managers.count == 0
      redirect_to new_admin_admin_path, notice: "Please add an account manager before adding job orders."
    end
    if params[:company_id]
    @company = Company.find(params[:company_id])
    @account_managers = @company.account_managers
    @order = @company.orders.new
    else
      @order = Order.new
      @account_managers = @current_agency.account_managers
      
    end
    authorize @order

  end
  
  def tag_cloud
    @tags = Order.tag_counts_on(:tags)
  end

  # GET /orders/1/edit
  def edit
   
    @order = Order.find(params[:id])
    @order.skills
    authorize @order
    @company = @order.company
    @account_managers = @company.account_managers if @company.account_managers.any?
    
    # @account_managers = @current_agency.admins.account_managers if @current_agency.present?
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
    @order.agency = @current_agency
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
        params.require(:order_import).permit(:file, :company_id)
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :address, :min_pay, :max_pay, :pay_frequency, :company_id, :agency_id, :account_manager_id, :manager_id, :mark_up, :title, :notes, 
      :number_needed, :needed_by, :urgent, :active, :dt_req, :bg_check, :stwb, :heavy_lifting, :shift, :est_duration, :tag_list, :aca_type,
      :education, :industry, :years_of_experience, :certifications, :requirement_1, :requirement_2, :requirement_3, :requirement_4, 
      :published_at, :published_by, :expires_at, :company_approval, :agency_approval, :mobile_time_clock_enabled,
      jobs_attributes: [:order_id, :title, :description, :start_date, :id, :employee_id, :active], 
      skills_attributes: [:id, :skillable_type, :skillable_id, :name, :required, :_destroy])
    end
end
