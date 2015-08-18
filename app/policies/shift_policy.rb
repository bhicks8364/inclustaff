class ShiftPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope
      end
      
    end
  
    def index?
        user.present? 
    end
    def clock_out?
        user.present? 
        # user.admin? || shift.employee_id == user.id
    end
    
    def show?
        scope.where(:id => shift.id).exists?
        
    end
    
    def create?
        return true if user.admin? 
        return true if user.employee? && user.employee.id == shift.job.employee_id
        # user.employee?
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
        user.not_an_employee?
    end
    
    

    
    
    private
    def shift
        record
    end
  
  
  
end
