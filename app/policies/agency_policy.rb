class AgencyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.present?
        scope.where(:agency_id => user.agency_id)
      end
    end
  end
  
  def index?
   user.present?
  end
  
  def show?
    # true
    return true if user.owner? || user.account_manager?
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
