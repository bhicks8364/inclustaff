class EmployeeQueryBuilder < ArelHelpers::QueryBuilder
  def initialize(query = nil)
    # whatever you want your initial query to be
    super(query || employee.unscoped)
  end

  def with_last_name_matching(last_name)
    reflect(
      query.where(employee[:last_name].matches("%#{last_name}%"))
    )
  end
  def with_first_name_matching(first_name)
    reflect(
      query.where(employee[:first_name].matches("%#{first_name}%"))
    )
  end
  def with_ssn_matching(ssn)
    reflect(
      query.where(employee[:ssn].matches("%#{ssn}%"))
    )
  end
  
  def since_yesterday
    reflect(
      query.where(employee[:created_at].gteq(Date.yesterday))
    )
  end

  private

  def job
    Job
  end

  def employee
    Employee
  end
end