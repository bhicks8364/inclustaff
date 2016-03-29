# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :string
#  first_name             :string
#  last_name              :string
#  deleted_at             :datetime
#  can_edit               :boolean
#  code                   :string
#  address                :string
#  city                   :string
#  state                  :string
#  zipcode                :string
#  employee_id            :integer
#  agency_id              :integer
#  resume_id              :integer
#  checked_in_at          :datetime
#  name                   :string
#  latitude               :float
#  longitude              :float
#  start_date             :date
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#
# Indexes
#
#  index_users_on_agency_id             (agency_id)
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_resume_id             (resume_id)
#  index_users_on_role                  (role)
#

class Admin::UsersController < ApplicationController
    # before_filter :authenticate_admin!
    layout "admin_layout"

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
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
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
            redirect_to admin_users_path, notice: "Imported #{@import_count} users."
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
        @job = @employee.current_job
        @timesheets = @employee.timesheets
        @work_histories = @employee.work_histories.order(end_date: :desc)
        @skills = @employee.skills
        @applications = @user.events.applications
        @events = Event.employee_events(@employee.id)
        @orders = Order.active if @employee.unassigned?
        @jobs = @employee.jobs.includes(:order)
        @shifts = @employee.shifts.order(time_out: :desc).limit(1)
        skip_authorization
    end
    
    def destroy
        @user = User.find(params[:id])
        skip_authorization
        @user.destroy
        respond_to do |format|
          format.html { redirect_to admin_users_path, notice: 'User was successfully destroyed.' }
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
    
end
