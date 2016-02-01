class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        if user.account_manager?
          scope.where(:account_manager_id => user.id)
        elsif user.class_name == "CompanyAdmin"
          scope.where(:company_id => user.company_id)
        else
          scope.none
        end
      elsif user.employee?
        scope.where(:id => user.employee.current_job.id)
      else
        scope.none
      end
    end
  end
  
  def create?
    user.account_manager? || user.owner?
  end
  
  def index?
    user.account_manager? || user.owner? || user.payroll?
  end
  def search?
    index?
  end
  

  def show?
    return true if user.admin? || user.owner? || user.payroll?
    user.employee? && record.employee_id == user.employee.id
  end
  def update?
    # return true if user.account_manager? || user.owner?
    return true if user.admin? || user.owner? || user.payroll?
    user.employee? && record.employee_id == user.employee.id
  end
  def destroy?
   user.admin? || user.company_admin?
  end
end
