class CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.present?
        scope.where(:company_id => user.company_id)
      end
    end
  end
  
  def index?
    user.present? && user.admin?
  end
  
  def show?
    return true if user.admin? || user.manager?
    return true if user.payroll? && user.can_edit?
  end
  
  def create?
    user.admin?
  end
  
  def new?
    create?
  end
  
  def update?
    user.admin?
  end
  
  def edit?
    update?
    
  end
  
  def destroy?
    false
  end
  
  
  
  
end
