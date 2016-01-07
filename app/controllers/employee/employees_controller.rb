class Employee::EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee
  layout "employee"

  def show
  end

  def edit
  end
  def update
    
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to employee_profile_path, notice: 'Your profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def set_employee
    @employee = Employee.find(params[:id])
    skip_authorization
  end
    def employee_params
      params.require(:employee).permit(:first_name, :last_name, :email, :ssn, :phone_number, :user_id, :resume, :dns, :tag_list, :skill_list,
          :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :desired_job_type, :desired_shift, 
          jobs_attributes: [:title, :pay_rate, :start_date, :order_id, :id], skills_attributes: [:id, :skillable_id, :skillable_type, :name, :required, :_destroy],
          user_attributes: [:id, :code, :email, :role, :password, :password_confirmation, :first_name, :last_name, :company_id, :current_password, :address, :city, :state, :zipcode],
          work_histories_attributes: [:id, :name, :employee_id, :employer_name, :start_date, :end_date, :title, :description, :current, :may_contact,
          :supervisor, :phone_number, :pay])
    end
end
