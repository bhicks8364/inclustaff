class TimesheetQueryBuilder < ArelHelpers::QueryBuilder
  def initialize(query = nil)
    # whatever you want your initial query to be
    super(query || timesheet.unscoped)
  end

  def with_week_matching(week)
    reflect(
      query.where(timesheet[:week].matches("%#{week}%"))
    )
  end

  def with_comments_by(usernames)
    reflect(
      query
        .joins(:comments => :job_order)
        .where(job_order[:username].in(usernames))
    )
  end

  def since_yesterday
    reflect(
      query.where(timesheet[:created_at].gteq(Date.yesterday))
    )
  end

  private

  def job_order
    Order
  end
  def company
    Company
  end

  def timesheet
    Timesheet
  end
end