class UsersController < ApplicationController
    before_filter :authenticate_admin!
    layout :determine_layout

    def index
        @users = @current_agency.users.available.includes(:employee).ordered_by_last_name
        # @users = User.includes(:employee).available
        @import = User::Import.new
        skip_authorization
        gon.users = @users
        @hash = Gmaps4rails.build_markers(@users) do |user, marker|
          marker.lat user.latitude
          marker.lng user.longitude
          marker.infowindow user.name
          marker.title user.name
        end
        
        @export = User.all
        
        respond_to do |format|
            format.html
            format.json
            format.csv { send_data @export.to_csv, filename: "users-export-#{Time.now}-inclustaff.csv" }
        end 

    end
    
    def dns_list
        @users = User.includes(:employee).dns
        skip_authorization
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
        if @employee.assigned? && admin_signed_in?
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
    def follow
      @user = User.find(params[:id])
      if admin_signed_in?
          @event = current_admin.events.create(action: "followed", eventable: @user)
      end
      skip_authorization
    end
    def update_as_available
        @user = User.includes(:employee, :shifts).find(params[:id])
        @user.update(checked_in_at: Time.current)
        Event.create(action: "looking_for_work", eventable: @user, user_id: @user.id)
        skip_authorization
    end
    
    private
    
    def user_import_params
        params.require(:user_import).permit(:file, :agency_id)
    end

    def user_params
        params.require(:user).permit(:id, :first_name, :last_name, :email, :role, :can_edit, :agency_id, :password, :password_confirmation, :address, :city, :state, :zipcode)
    end
    
    def determine_layout
      if admin_signed_in?
        "admin_layout"
      elsif company_admin_signed_in?
        "company_layout"
      elsif user_signed_in?
        "employee"
      else
          "application"
      end
    end
    
end