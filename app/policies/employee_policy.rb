class EmployeePolicy < ApplicationPolicy
    def index?
        # scope.where(:id => employee.id).exists?
        # return true if  user.present? && user.admin? 
    end
    
    def show?
        true
        # scope.where(:id => employee.id).exists?
        # return true if admin_signed_in?
        # return true if user.manager?
        # return true if user.present? && user.id == employee.user_id
        # user.not_an_employee?

    end
    
    def create?
        # user.not_an_employee?
    end
    
    def new?
        create?
    end
    def update?
        # user.not_an_employee?
    end
    
    def edit?
        update?
    end

    def destroy?
        # user.admin?
        # user.not_an_employee?
    end
    
    

    
    
    private
    def employee
        record
    end
    
end