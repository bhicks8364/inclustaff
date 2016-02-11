class CompanyAdminPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def create?
    return true if user.owner? || user.payroll?
  end
  
  def index?
    return true if user.owner? || user.payroll?
    
  end
  def update?
    return true if user.owner? || user.payroll?
  end
  
  def destroy?
    return true if user.owner? || user.payroll?
    
  end
end
