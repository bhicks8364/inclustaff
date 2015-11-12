class TimesheetQueryBuilder < ArelHelpers::QueryBuilder
  def initialize(query = nil)
    # whatever you want your initial query to be
    super(query || timesheet.unscoped)
  end

  def billing_mare_than(amount)
    reflect(
      query.where(timesheet[:total_bill].gteq(amount))
    )
  end

  def with_admin_comments_by(admin_id)
    reflect(query.joins(:comments).where(comment[:admin_id].eq(admin_id)).distinct)
  end
  
  def with_company_comments_by(company_admin_id)
    reflect( query.joins(:comments).where(comment[:company_admin_id].eq(company_admin_id))).distinct
  end
  def with_user_comments_by(user_id)
    reflect( query.joins(:comments).where(comment[:user_id].eq(user_id))).distinct
  end

  def since_yesterday
    reflect(query.where(timesheet[:created_at].gteq(Date.yesterday)))
  end

  private

  def job_order
    Order
  end
  def comment
    Comment
  end

  def timesheet
    Timesheet.includes(:job)
  end
end