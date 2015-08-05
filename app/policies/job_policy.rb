class JobPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  
    def index?
        user.present? && user.not_an_employee?
    end
    
    def show?
        scope.where(:id => job.id).exists?
        return true if user.present? && user.not_an_employee?
        return true if user.employee.id == @record.employee_id && user.employee?
    end
    
    def create?
        user.not_an_employee?
    end
    
    def new?
        create?
    end
    def update?
        user.admin?
        # user.not_an_employee?
    end
    
    def edit?
        update?
    end

    def destroy?
        user.admin?
    end
    
    private
    def job
        record
    end
  
  
end
