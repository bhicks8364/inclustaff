class InvoicePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def create?
    return true if user.agency?
  end
  
  def index?
    return true if user.agency?
    
  end
  def update?
    return true if user.agency?
  end
  
  def destroy?
    return true if user.agency?
    
  end
end
