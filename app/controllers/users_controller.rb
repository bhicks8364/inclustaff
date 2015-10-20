class UsersController < ApplicationController
    layout :determine_layout
    def index
        @users = User.includes(:employee)
        @import = User::Import.new
        skip_authorization
        
        respond_to do |format|
            format.html
            format.json
            format.csv { send_data @users.to_csv, filename: "users-export-#{Time.now}-inclustaff.csv" }
        end 
        
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
        @job = @user.current_job
        @employee = @user.employee
        @skills = @employee.skills
        # @company = @employee.company
        @applications = @user.events.applications
        @events = Event.employee_events(@user.id)
        @orders = Order.active if @employee.unassigned?
        # @job = @employee.current_job if @employee.assigned?
        
        @jobs = @employee.jobs.includes(:order)
        @shifts = @employee.shifts.order(time_out: :desc).limit(1)
        @timesheets = @employee.timesheets
        @work_histories = @employee.work_histories.order(end_date: :desc)
        # @company = @user.company
        # @employee = @user.employee if @user.employee?
        # @job = @employee.current_job if @employee.present?
        # @jobs = @employee.jobs if @employee.jobs.any?
        # @timesheets = @employee.timesheets if @employee.present?

            
        
        skip_authorization
    end
    
    private
    
    def user_import_params
        params.require(:user_import).permit(:file)
    end

    def user_params
        params.require(:user).permit(:id, :first_name, :last_name, :email, :role, :can_edit, :company_id, :password, :password_confirmation, :address, :city, :state, :zipcode)
    end
    
      def determine_layout
        current_admin ? "admin_layout" : "application"
      end
    
end