class AdminsController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin_layout'
    def index
        
        @agency_admins = @current_agency.admins.agency_admins.order(role: :asc) if @current_agency.present?
        # @admins = @current_agency.agency_admins.order(role: :asc)
          # @admins = @company.admins.order(last_name: :asc) if @company.present?
          # @admins = @agency.admins.order(last_name: :asc) if @agency.present?
        skip_authorization
        respond_to do |format|
          format.json
          format.html

      end
    end
    
    def follow
      @admin = Admin.find(params[:id])
      @event = current_admin.events.create(action: "followed", eventable: @admin)
      
      if @event.save
        redirect_to admins_path, notice: 'You are now following ' + "#{@admin.name}"
        
      else
        redirect_to admins_path, notice: 'Unable to follow ' + "#{@admin.name}"
      end
    skip_authorization
    end
    
    
    def edit
        @admin = Admin.find(params[:id])
      skip_authorization
    end
    def update
      @admin = Admin.find(params[:id])
      skip_authorization
      respond_to do |format|
        if @admin.update(admin_params)
          format.html { redirect_to @admin, notice: 'Admin info was successfully updated.' }
          format.json { render :show, status: :ok, location: @admin }
        else
          format.html { render :edit }
          format.json { render json: @admin.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def show
        
        @admin = Admin.find(params[:id])
        if @admin.company?
            @company = @admin.company
            @employees = @company.employees
            @orders = @company.orders
            @events = @admin.events
            @company_orders = @company.orders if @admin.owner?
            @company_jobs = @company.jobs if @company.jobs.any?
            @jobs = @company.jobs.with_current_timesheets.distinct if @admin.company?
            @timesheets = @company.timesheets
        elsif @admin.agency?
            @agency = @admin.agency
            @employees = Employee.all.limit(5).order(:last_name)
            @orders = @agency.orders
            @acct_orders = @admin.account_orders if @admin.account_manager?
            @events = @admin.events
            @recruiter_jobs = @admin.recruiter_jobs.with_current_timesheets.distinct if @admin.recruiter?
            @jobs = @agency.jobs.with_current_timesheets.distinct if @admin.agency?
            @timesheets = @agency.timesheets
            
        end
        
        # @employees = @company.employees if @company.employees.any?
        # @jobs = Job.by_recuriter(@admin).with_current_timesheets if @admin.recruiter?
        # @jobs = @company.jobs.active if @company.jobs.any?


            
        
        skip_authorization
    end
    
    private
    def admin_params
      params.require(:admin).permit(:first_name, :last_name, :email, :username, :role)
    end
    
    
    
end