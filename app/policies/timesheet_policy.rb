class TimesheetPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope
      end
      
    end
  
    def index?
        user.present? && user.not_an_employee?
    end
    def clock_out?
        timesheet.employee_id == user.id
    end
    
    def show?
        scope.where(:id => timesheet.id).exists?
        
    end
    
    def create?
        # true
        user.admin?
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
        # user.not_an_employee?
    end
    
    

    
    
    private
    def timesheet
        record
    end
end
