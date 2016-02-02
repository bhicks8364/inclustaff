class JobPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        if user.recruiter?
          scope.where(:recruiter_id => user.id)
        else
          scope.all
        end
      elsif user.employee?
        scope.where(:id => user.employee.current_job.id)
      else
        scope.none
      end
    end
  end

  def create?
    user.admin?
  end

  def index?
    user.admin?
  end

  def clock_in?
    return true if user.owner?
    user.employee? && user.employee.current_job.order.mobile_time_clock_enabled? && record.id == user.employee.current_job.id
  end

  def clock_out?
    return true if user.owner?
    user.employee? && user.employee.current_job.order.mobile_time_clock_enabled? && record.id == user.employee.current_job.id
  end

  def show?
    return true if user.admin? || user.company_admin?
    user.employee? && record.employee_id == user.employee.id
  end

  def approve?
    user.admin? && user.account_manager? || user.owner?
  end

  def cancel?
    user.admin? && user.account_manager? || user.owner?
  end

  def update?
    return true if user.admin?
    user.employee? && record.employee_id == user.employee.id
  end

  def destroy?
    false
  end
end
