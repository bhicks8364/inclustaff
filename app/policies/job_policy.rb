class JobPolicy < ApplicationPolicy
    class Scope < Scope
        def resolve
            if user.recruiter?
                scope.where(:recruiter_id => user.id)
            else
                scope
            end
        end
    end
  
    def index?
        if user.role != "Employee"
            return true if user.present?

        elsif user.role == "Employee"
            user.employee.assigned?
        end
        # scope.where(:recruiter_id => user.id)
       
        # return true if user.manager? && job.order.manager_id == user.id
        # return true if user.employee.id == job.employee_id && user.employee?
        
    end
    
    def show?
        if user.role != "Employee"
            return true if user.present?

        elsif user.role == "Employee"
            user.employee.assigned?
        end
        
        
        # scope.where(:id => job.id).exists?
        # return true if user.admin? || user.payroll?
        # return true if user.manager? && job.order.manager_id == user.id
        # return true if user.employee.id == job.employee_id && user.employee?
    end
    
    def create?
        if user.role != "Employee"
            
            
            return true if user.owner? || user.payroll? || user.recruiter?

        elsif user.role == "Employee"
            return true if user.employee?
        end
    end
    def clock_in?
        if user.role != "Employee"
            
            return true if user.owner? || user.payroll?
            user.recruiter? && user.id == job.recruiter_id

        elsif user.role == "Employee"
            return true if user.employee?
        end
        
        
        
        
    end
    def clock_out?
        if user.role != "Employee"
            
            return true if user.owner? || user.payroll? || user.recruiter?
            

        elsif user.role == "Employee"
            return true if user.employee?
        end
    end
    
    def new?
        create?
    end
    def update?
        return true if user.owner? || user.payroll?
        return true if user.recruiter? || user.account_manager?
        
        # true
        # user.admin?
        # user.not_an_employee?
    end
    
    def edit?
        update?
    end

    def destroy?
        user.account_manager? || user.owner?
    end
    
    private
    def job
        record
    end
  
  
end
