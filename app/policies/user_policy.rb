class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  
    def index?
        user.present? && user.not_an_employee?
    end
    
    def all?
        user.present? && user.not_an_employee?
    end
    
    def show?
        scope.where(:id => record.id).exists?
        return true if user.not_an_employee? && user.company_id == record.company_id
        return true if user.id == record.id && user.employee?
        
    end
    
    def create?
        user.present? && user.not_an_employee?
    end
    
    def new?
        create?
    end
    def update?
        user.present? && user.not_an_employee?
    end
    
    def edit?
        update?
    end

    def destroy?
        # user.not_an_employee?
    end
    def grant_editing?
        user.admin?
        # user.not_an_employee?
    end
    
    

    
    
    private
    def record
        record
    end
    
  
  
end