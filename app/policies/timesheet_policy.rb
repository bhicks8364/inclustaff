class TimesheetPolicy < ApplicationPolicy
    # class Scope < Scope
    #   def resolve
    #     scope
    #   end
      
    # end
  
    def index?
        true
        # pundit_user.present?
        # user.present? && user.not_an_employee?
    end
    def approve?
        user.owner? || user.payroll?
        
    end
    
    def show?
        if user.class == "Admin"
            user.owner? || user.payroll?
        else
            user.employee.assigned?
        end
        # scope.where(:id => timesheet.id).exists?
        
    end
    
    def create?
        # true
        # user.admin?
    end
    
    def new?
        create?
    end
    def update?
        user.owner? || user.payroll?
    end
    
    def edit?
        update?
    end

    def destroy?
        # user.not_an_employee?
    end
    
    # def pundit_user
    #     @current_admin
    # end
    

    
    
    # private
    # def timesheet
    #     record
    # end
end
