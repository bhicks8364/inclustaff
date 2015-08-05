class CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # if user.present?
      # scope.all
      # end
    end
  end
  
  def index?
    user.present? && user.admin?
  end
  
  def show?
    true
  end
  
  def create?
    true
  end
  
  def new?
    true
  end
  
  def update?
    true
  end
  
  def edit?
    true
  end
  
  def destroy?
    true
  end
  
  
  
  
end
