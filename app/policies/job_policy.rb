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
        
        # scope.where(:recruiter_id => user.id)
        return true if user.recruiter? || user.owner?
        # return true if user.manager? && job.order.manager_id == user.id
        # return true if user.employee.id == job.employee_id && user.employee?
        
    end
    
    def show?
        user.recruiter? && user.id == job.recruiter_id
        # scope.where(:id => job.id).exists?
        # return true if user.admin? || user.payroll?
        # return true if user.manager? && job.order.manager_id == user.id
        # return true if user.employee.id == job.employee_id && user.employee?
    end
    
    def create?
        # user.not_an_employee?
    end
    def clock_in?
        return true if user.owner? || user.payroll?
        user.recruiter? && user.id == job.recruiter_id
    end
    def clock_out?
        return true if user.owner? || user.payroll?
        user.recruiter? && user.id == job.recruiter_id
    end
    
    def new?
        create?
    end
    def update?
        return true if user.owner? || user.payroll?
        user.recruiter? && user.id == job.recruiter_id
        
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
