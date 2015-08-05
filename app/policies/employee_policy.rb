class EmployeePolicy < ApplicationPolicy
    def index?
        # scope.where(:id => employee.id).exists?
        return true if  user.present? && user.admin? 
    end
    
    def show?
        scope.where(:id => employee.id).exists?
        return true if user.present? && user.not_an_employee?
        return true if user.id == employee.user_id && user.employee?
        
    end
    
    def create?
        user.not_an_employee?
    end
    
    def new?
        create?
    end
    def update?
        user.not_an_employee?
    end
    
    def edit?
        update?
    end

    def destroy?
        user.admin?
        # user.not_an_employee?
    end
    
    

    
    
    private
    def employee
        record
    end
    
end