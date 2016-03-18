class TimesheetPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.employee
        scope.where(:job_id => user.employee.current_job.id)
      else
        scope.none
      end
    end
  end
  
  def index?
    user.present?
  end
  def past?
    user.present?
  end
  def create?
    user.admin? || user.company_admin?
  end
  def approve?
    user.admin? || user.company_admin?
  end
  def show?
    return true if user.admin? || user.company_admin?
    user.employee? && record.job_id == user.employee.current_job.id
  end
  def edit
    update?
  end
  def update?
    true
    # return true if user.admin? && record.pending?
    
  end
  def destroy?
    return true if user.admin?
    
  end
end
