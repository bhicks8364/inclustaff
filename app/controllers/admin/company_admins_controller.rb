# == Schema Information
#
# Table name: company_admins
#
#  id                     :integer          not null, primary key
#  first_name             :string
#  last_name              :string
#  phone_number           :string
#  company_id             :integer
#  role                   :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  latitude               :float
#  longitude              :float
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
#  index_company_admins_on_confirmation_token    (confirmation_token) UNIQUE
#  index_company_admins_on_email                 (email) UNIQUE
#  index_company_admins_on_invitation_token      (invitation_token) UNIQUE
#  index_company_admins_on_invitations_count     (invitations_count)
#  index_company_admins_on_invited_by_id         (invited_by_id)
#  index_company_admins_on_reset_password_token  (reset_password_token) UNIQUE
#  index_company_admins_on_unlock_token          (unlock_token) UNIQUE
#

class Admin::CompanyAdminsController < ApplicationController
    layout "admin_layout"
    
  def index
      if admin_signed_in?
        @q = CompanyAdmin.real_users.includes(:company).ransack(params[:q]) 

         @company_admins = @q.result(distinct: true).order('companies.name').paginate(page: params[:page], per_page: 10) if @q.present?
         @timeclocks = CompanyAdmin.timeclocks.includes(:company).order('companies.name').paginate(page: params[:page], per_page: 10)
      elsif company_admin_signed_in?
          @company_admins = @current_company.admins.real_users.paginate(page: params[:page], per_page: 10) 
          @q = @company_admins.includes(:company).ransack(params[:q]) 
      end
      gon.admins = CompanyAdmin.real_users
      skip_authorization
  end
  
  def show
    @company_admin = CompanyAdmin.find(params[:id])
    @company = @company_admin.company
    if @company_admin.role == "Timeclock"
      render "company/dashboard/timeclock"
    end
    skip_authorization
  end
  
  def follow
    @company_admin = CompanyAdmin.find(params[:id])
    @event = current_admin.events.create(action: "followed", eventable: @company_admin)
    
    skip_authorization
  end
    
  def new
    @company_admin = CompanyAdmin.new
    skip_authorization
  end
  
  def edit
    @company_admin = CompanyAdmin.find(params[:id])
    skip_authorization
  end
  def update
    @company_admin = CompanyAdmin.find(params[:id])
    skip_authorization
    respond_to do |format|
      if @company_admin.update(company_admin_params)
        format.html { redirect_to admin_company_admins_path, notice: 'Company Admin was successfully updated.' }
        format.json { render :show, status: :ok, location: @company_admin }
      else
        format.html { render :edit }
        format.json { render json: @company_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    # @company_admin = CompanyAdmin.invite! company_admin_params
    @company_admin = CompanyAdmin.new(company_admin_params) 
    @company_admin.password = "password"
    @company_admin.password_confirmation = "password"
    @company_admin.save
    if @company_admin.persisted?
      redirect_to admin_company_admins_path, notice: 'You just added ' + "#{@company_admin.name}" + " as a #{@company_admin.role} at #{@company_admin.company.name}. They will receive an email with further instructions."
    else
      redirect_to admin_company_admins_path, notice: 'Unable to add company admin'
    end
    skip_authorization
  end
  private

  def company_admin_params
    params.require(:company_admin).permit(:first_name, :last_name, :email, :username, :role, :company_id, :password, :password_confirmation)
  end
end
