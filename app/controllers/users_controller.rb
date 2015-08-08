class UsersController < ApplicationController
    def grant_editing
        @user = User.find(params[:id])
        authorize @user
        if @user.can_edit?
            @user.update(can_edit: false)
        else
            @user.update(can_edit: true)
        end
    end
    
    def show
        @user = User.find(params[:id])
        @company = current_user.company
        @employees = @company.employees
        @employee = @user.employee if @user.employee?
        skip_authorization
    end
    
    
    
end