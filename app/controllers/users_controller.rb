class UsersController < ApplicationController
    
    def index
        @users = User.all
        skip_authorization
        
        # if admin_signed_in? 
        #   @admin = current_admin
        #   @company = @admin.company
        #   @users = @company.users.order(last_name: :asc)
        # elsif user_signed_in? && current_user.not_an_employee?
        #   @current_user = current_user if current_user.present?
        #   @company = @current_user.company
        #   @users = @company.users.order(last_name: :asc)
        # end
    end
    
    
    def grant_editing
        @user = User.find(params[:id])
        if @user.can_edit?
            @user.update(can_edit: false)
        else
            @user.update(can_edit: true)
        end
        skip_authorization
    end
    
    def show
        @user = User.includes(:employee, :shifts).find(params[:id])
        @job = @user.current_job
        @employee = @user.employee
        @company = @employee.company
        # @job = @employee.current_job if @employee.assigned?
        
        @jobs = @employee.jobs.includes(:order)
        @shifts = @employee.shifts.order(time_out: :desc).limit(1)
        @timesheets = @employee.timesheets
        # @company = @user.company
        # @employee = @user.employee if @user.employee?
        # @job = @employee.current_job if @employee.present?
        # @jobs = @employee.jobs if @employee.jobs.any?
        # @timesheets = @employee.timesheets if @employee.present?

            
        
        skip_authorization
    end
    
    
    
end