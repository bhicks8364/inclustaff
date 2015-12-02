class WorkHistoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def create?
    true
  end
  
  def index?
    return true if user.admin?
    user.employee?
  end
  def show?
    return true if user.admin?
    user.employee? && record.employee_id == user.employee.id
  end
  def update?
    return true if user.admin?
    user.employee? && record.employee_id == user.employee.id
  end
  def destroy?
    return true if user.admin?
    user.employee? && record.employee_id == user.employee.id
  end
end
