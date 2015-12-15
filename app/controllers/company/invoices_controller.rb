class Company::InvoicesController < ApplicationController
  before_action :set_company
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]
  layout "company_layout"
  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = @company.invoices

    
    skip_authorization
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show

      @invoice = Invoice.find(params[:id])

    skip_authorization
  end

  # GET /invoices/new
  def new
    @company = Company.find(params[:company_id])
    @invoice = @company.invoices.new
    skip_authorization
  end

  # GET /invoices/1/edit
  def edit
    if params[:company_id]
      @company = Company.find(params[:company_id])
      @invoice = Invoice.find(params[:id])
    else
      
      @invoice = Invoice.find(params[:id])
      render 'invoices/edit'
    end
    
    skip_authorization
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @company = Company.find(params[:company_id]) if params[:company_id]
    @invoice = @company.invoices.new(invoice_params)
    @invoice.agency = @current_agency
    skip_authorization
    respond_to do |format|
      if @invoice.save
        @company = @invoice.company
        format.html { redirect_to company_invoice_path(@company, @invoice), notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def mark_as_paid
    @invoice = Invoice.includes(:company).find(params[:id])
      skip_authorization
      if @invoice.timesheets.pending.any?
        render json: { notice: "Invoice ID: #{@invoice.id}" + "is #{@invoice.state}." + "Cannot pay invoice until all invoices are approved."} 
      elsif @invoice.unpaid? && @invoice.timesheets_approved?
        @current_company_admin.events.create(action: 'paid', eventable: @invoice)
        render json: { id: @invoice.id, paid: @invoice.paid?, date_paid: @invoice.paid_on,
                     balance: @invoice.balance }
      else
        render json: { notice: "Invoice ID: #{@invoice.id}" + "is #{@invoice.state}." }
      end
    
    
        
      # company_name = @invoice.company.name
      # balance = @invoice.balance.round(2)
      
    
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    
    respond_to do |format|
      if @invoice.update(invoice_params)
        @company = @invoice.company
        format.html { redirect_to company_company_invoice_path(@company, @invoice), notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @company = @invoice.company
    @invoice.destroy
    respond_to do |format|
     
      format.html { redirect_to company_company_invoices_path(@company), notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    
    def set_company
      @current_company_admin = current_company_admin
      @company = @current_company_admin.company
      skip_authorization
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      
      @invoice = Invoice.find(params[:id])
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:company_id, :agency_id, :week, :due_by, :paid, :total, :amt_paid, :date_paid)
    end
end
