class CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # if user.present?
      #   scope.where(:company_id => user.company_id)
      # end
    end
  end
  
  def index?
    if user.role != "Employee"
        return true if user.present?

    elsif user.role == "Employee"
        false
    end
   
  end
  
  def show?
    if user.role != "Employee"
        return true if user.present?

    elsif user.role == "Employee"
        false
    end
  end
  
  def create?
    if user.role != "Employee"
        return true if user.present?

    elsif user.role == "Employee"
        false
    end
  end
  
  def new?
    create?
  end
  
  def update?
    if user.role != "Employee"
        return true if user.present?

    elsif user.role == "Employee"
        false
    end
  end
  
  def edit?
    update?
    
  end
  
  def destroy?
    false
  end
  
  
  
  
end
