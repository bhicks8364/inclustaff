class EmployeeQueryBuilder < ArelHelpers::QueryBuilder
  def initialize(query = nil)
    # whatever you want your initial query to be
    super(query || employee.unscoped)
  end

  def with_title_matching(title)
    reflect(
      query.where(post[:title].matches("%#{title}%"))
    )
  end

  def unassigned
    reflect(
      query
        .joins(:jobs)
        .where(Job[:employee_id].not_eq(employee[:id]))
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