class UsersController < ApplicationController
    
    # def index
    #     if admin_signed_in? 
    #       @admin = current_admin
    #       @company = @admin.company
    #       @users = @company.users.order(last_name: :asc)
    #     elsif user_signed_in? && current_user.not_an_employee?
    #       @current_user = current_user if current_user.present?
    #       @company = @current_user.company
    #       @users = @company.users.order(last_name: :asc)
    #     end
    # end
    
    
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
        @company = @admin.company
        @employees = @company.employees


            
        
        skip_authorization
    end
    
    
    
end