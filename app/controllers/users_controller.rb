class UsersController < ApplicationController
    layout :determine_layout
    
    def index
        @users = @current_agency.users.available.ordered_by_check_in
        # @users = User.includes(:employee).available
        @import = User::Import.new
        skip_authorization
        
        respond_to do |format|
            format.html
            format.json
            format.csv { send_data @users.to_csv, filename: "users-export-#{Time.now}-inclustaff.csv" }
        end 

    end
    
    def dns_list
        @users = User.includes(:employee).dns
    end
    
    def edit
        @user = User.find(params[:id])
        skip_authorization
    end
    
  def update
    @user = User.find(params[:id])
    skip_authorization
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
        
    
    def import
        @import  = User::Import.new(user_import_params)
        
        if @import.save
            redirect_to users_path, notice: "Imported #{@import_count} users."
        else
            @users = User.all
            render action: :index, notice: "There were errors with your CSV file."
        end
        skip_authorization
        
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
        @employee = @user.employee
        @timesheets = @employee.timesheets
        @work_histories = @employee.work_histories.order(end_date: :desc)
        @skills = @employee.skills
        if @user.assigned?
            render "admin/employees/show"
        end
        @job = @user.current_job
        @employee = @user.employee
        
        # @company = @employee.company
        @applications = @user.events.applications
        @events = Event.employee_events(@employee.id)
        @orders = Order.active if @employee.unassigned?
        # @job = @employee.current_job if @employee.assigned?
        
        @jobs = @employee.jobs.includes(:order)
        @shifts = @employee.shifts.order(time_out: :desc).limit(1)
        
        

        skip_authorization
    end
    
    def destroy
        @user = User.find(params[:id])
        skip_authorization
        @user.destroy
        respond_to do |format|
          format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
          format.json { head :no_content }
        end
    end
    def update_as_available
        @user = User.includes(:employee, :shifts).find(params[:id])
        @user.update(checked_in_at: Time.current)
        @user.events.create(action: "looking for work")
        skip_authorization
    end
    
    private
    
    def user_import_params
        params.require(:user_import).permit(:file)
    end

    def user_params
        params.require(:user).permit(:id, :first_name, :last_name, :email, :role, :can_edit, :agency_id, :password, :password_confirmation, :address, :city, :state, :zipcode)
    end
    
      def determine_layout
        current_admin ? "admin_layout" : "application"
      end
    
end