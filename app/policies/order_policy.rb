class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  
    def index?
        user.present? && user.not_an_employee?
    end
    
    def all?
        user.present? && user.not_an_employee?
    end
    
    def show?
        scope.where(:id => order.id).exists?
        return true if user.present? && user.not_an_employee?
        # return true if user.company_id == order.company_id && user.not_an_employee?
        
    end
    
    def create?
        user.admin?
    end
    
    def new?
        create?
    end
    def update?
        return true if user.company_id == order.company_id && user.not_an_employee?
    end
    
    def edit?
        update?
    end

    def destroy?
        # user.not_an_employee?
    end

    
    

    
    
    private
    def order
        record
    end
    
  
  
end
