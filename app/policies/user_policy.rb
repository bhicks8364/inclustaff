class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  
    def index?
       
    end
    
    def all?
       
    end
    
    def show?
        scope.where(:id => record.id).exists?
        
    end
    
    def create?
        
    end
    
    def new?
        create?
    end
    def update?
        user.present? 
    end
    
    def edit?
        update?
    end

    def destroy?
    
    end
    def grant_editing?
        
    end
    
    

    
    
    private
    def record
        record
    end
    
  
  
end