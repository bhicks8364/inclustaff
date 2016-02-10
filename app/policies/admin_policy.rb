class AdminPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  def create?
    return true if user.admin? 
  end
  
  def index?
    return true if user.admin? 
    
  end
  def update?
    return true if user.admin? 
  end
  
  def destroy?
    return true if user.admin? 
    
  end
end
