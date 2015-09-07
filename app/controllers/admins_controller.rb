class AdminsController < ApplicationController
    
    def index
        
          @admin = current_admin
          @company = @admin.company
          @admins = @company.admins.order(last_name: :asc)
        
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
        @orders = @admin.account_orders if @admin.account_manager?
        @company = @admin.company
        @orders = @company.orders if @admin.owner?
        @jobs = @company.jobs.with_current_timesheets.distinct if @admin.owner?
        
        @jobs = @admin.jobs.with_current_timesheets.distinct if @admin.account_manager?
        @jobs = @admin.recruiter_jobs.with_current_timesheets.distinct if @admin.recruiter?
        
        @employees = @company.employees
        # @jobs = Job.by_recuriter(@admin).with_current_timesheets if @admin.recruiter?
        # @jobs = @company.jobs.active if @company.jobs.any?


            
        
        skip_authorization
    end
    
    
    
end