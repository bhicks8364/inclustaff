class ShiftPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope
      end
      
    end
  
    def index?
        true
    end
    def clock_out?
        # shift.employee_id == user.id
        user.present?
    end
    
    def show?
        scope.where(:id => shift.id).exists?
    end
    
    def create?
        user.employee? && user.employee.id == shift.job.employee_id
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
        user.admin?
    end
    
    

    
    
    private
    def shift
        record
    end
  
  
  
end
