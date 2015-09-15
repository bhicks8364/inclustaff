class AdminsController < ApplicationController
    before_filter :authenticate_admin!
    layout 'admin_layout'
    def index
      @admin = current_admin
        if @admin.agency?
          @agency = @admin.agency
        elsif @admin.company?
          @company = @admin.company
        end
        @admins = Admin.agency_admins.where(agency_id: @admin.agency_id).order(role: :asc)
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
    
    
    # def grant_editing
    #     @user = User.find(params[:id])
    #     # authorize @user
    #     if @user.can_edit?
    #         @user.update(can_edit: false)
    #     else
    #         @user.update(can_edit: true)
    #     end
    # end
    
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
    
    
    
end