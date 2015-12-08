class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        if user.recruiter?
          scope.where(:recruiter_id => user.id)
        elsif user.class_name == "CompanyAdmin"
          scope.where(:company_id => user.company_id)
        else
          scope.none
        end
      elsif user.employee?
        scope.where(:id => user.employee.current_job.id)
      else
        scope.none
      end
    end
  end
  def create?
    return true if user.recruiter? || user.owner?
  end
  
  def index?
    return true if user.admin?
  end

  def show?
    return true if user.admin?
    user.employee? && record.employee_id == user.employee.id
  end
  def update?
    return true if user.recruiter? || user.owner?
    user.employee? && record.employee_id == user.employee.id
  end
  def destroy?
    false
  end
end
