class CompanyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        if user.account_manager?
          c = user.companies.distinct.pluck(:id)
          scope.where(:id => c)
        elsif user.recruiter? || user.limited?
          scope.none
        else
          scope.all
        end

      else
        scope.none
      end
    end
  end

  def create?
    user.account_manager? || user.owner?
  end

  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin? && user.owner?
  end
end
