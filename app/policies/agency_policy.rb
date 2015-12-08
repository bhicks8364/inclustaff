class AgencyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
          scope.all
        
      else
          scope.none
      end
    end
  end
  def create?
    return true 
  end
  
  def index?
    return true if user.admin?
  end
 
  def show?
    return true if user.agency_id == record.id
  end
  def update?
    user.owner? && user.agency_id == record.id && user.company_id == nil
  end
  def destroy?
    false
  end
end
