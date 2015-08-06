class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
        if user.admin?
            scope.all
        elsif user.manager?
            scope.where(:manager_id => user.id)
        else
            scope.where(:company_id => user.company_id)
        end
    end
  end
  
  
    def index?
        user.present? && user.not_an_employee?
        # return true if user.admin? || user.payroll? && user.can_edit?
        # return true if user.manager? && order.manager_id == user.id && user.can_edit?
        # user.admin? || user.manager? && user.can_edit?
    end
    
    def all?
        user.admin?
    end
    
    def show?
        scope.where(:id => order.id).exists?
        return true if user.admin? || user.payroll? && user.can_edit?
        return true if user.manager? && order.manager_id == user.id && user.can_edit?
        # return true if user.company_id == order.company_id && user.not_an_employee?
        
    end
    
    def create?
        user.admin?
    end
    
    def new?
        create?
    end
    def update?
        user.admin || user.manager? && user.can_edit?
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
