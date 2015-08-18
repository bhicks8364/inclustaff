class UsersController < ApplicationController
    
    def index
        if admin_signed_in? 
          @admin = current_admin
          @company = @admin.company
          @users = @company.company_users.order(last_name: :asc)
        elsif user_signed_in? && current_user.not_an_employee?
          @current_user = current_user if current_user.present?
          @company = @current_user.company
          @users = @company.company_users.order(last_name: :asc)
        end
    end
    
    
    def grant_editing
        @user = User.find(params[:id])
        # authorize @user
        if @user.can_edit?
            @user.update(can_edit: false)
        else
            @user.update(can_edit: true)
        end
    end
    
    def show
        @user = User.find(params[:id])
        @company = @user.company
        @employees = @company.employees
        @employee = @user.employee if @user.employee?
        @job = @employee.current_job if @employee.present?
        @manager = @user if @user.manager?
        
        if @user.employee?
            @timesheets = @employee.timesheets.this_week.order(updated_at: :desc)
        elsif @user.not_an_employee?
            @timesheets = @company.timesheets.this_week.order(updated_at: :desc)
        end
            
        
        skip_authorization
    end
    
    
    
end