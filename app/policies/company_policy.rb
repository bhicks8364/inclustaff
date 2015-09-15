class CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.present?
        scope.where(:company_id => user.company_id)
      end
    end
  end
  
  def index?
   return true if user.agency?
  end
  
  def show?
    # true
    return true if user.owner? || user.account_manager? || user.payroll?
    # return true if user.payroll? && user.can_edit?
    # return true if user.employee? || user.company_id == company.id
  end
  
  def create?
   return true if user.owner? || user.account_manager?
  end
  
  def new?
    create?
  end
  
  def update?
    return true if user.owner? || user.account_manager?
  end
  
  def edit?
    update?
    
  end
  
  def destroy?
    false
  end
  
  
  
  
end
