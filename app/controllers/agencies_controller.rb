class AgenciesController < ApplicationController
  before_action :set_agency, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_admin!
  layout 'admin_layout'
  # GET /agencies
  # GET /agencies.json
  def index
    
    @agencies = Agency.all
    authorize @agencies
  end

  # GET /agencies/1
  # GET /agencies/1.json
  def show
   
  end

  # GET /agencies/new
  def new
    @agency = Agency.new
    @agency.build_admin
    skip_authorization
  end

  # GET /agencies/1/edit
  def edit
    # authorize @agency
  end

  # POST /agencies
  # POST /agencies.json
  def create
    
    @agency = Agency.create(agency_params)
    @agency.admin.agency_id = @agency.id
    skip_authorization
    
    respond_to do |format|
      if @agency.save
        sign_in(@agency.admin)
        format.html { redirect_to admin_dashboard_path, notice: 'Welcome to IncluStaff!!' }
        format.json { render :show, status: :created, location: @agency }
      else
        format.html { render :new }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agencies/1
  # PATCH/PUT /agencies/1.json
  def update
    # authorize @agency
    respond_to do |format|
      if @agency.update(agency_params)
        format.html { redirect_to @agency, notice: 'Agency was successfully updated.' }
        format.json { render :show, status: :ok, location: @agency }
      else
        format.html { render :edit }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agencies/1
  # DELETE /agencies/1.json
  def destroy
    
    @agency.destroy
    authorize @agency
    respond_to do |format|
      format.html { redirect_to agencies_url, notice: 'Agency was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def pundit_user
      current_admin
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_agency
      @agency = Agency.includes(:orders, :users).find(params[:id])
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agency_params
      params.require(:agency).permit(:name, :subdomain, :admin_id, :order_ids => [], :admin_ids => [], :user_ids => [],
      admin_attributes: [:id, :email, :role, :password, :password_confirmation, :first_name, :last_name, :agency_id, :current_password])
    end
end
