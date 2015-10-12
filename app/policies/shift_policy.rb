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
        # scope.where(:id => shift.id).exists?
       user.owner? || user.payroll? || user.recruiter?
        
    end
    
    def create?
        user.owner? || user.payroll?
        # return true if user.admin? 
        # return true if user.employee? && user.employee.id == shift.job.employee_id
        # user.employee?
    end
    
    def new?
        create?
    end
    def update?
        user.owner? || user.payroll? || user.recruiter?
    end
    
    def edit?
        update?
    end

    def destroy?
        user.owner? || user.payroll?
    end
    
    

    
    
    private
    def shift
        record
    end
  
  
  
end
