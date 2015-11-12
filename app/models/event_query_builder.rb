class EventQueryBuilder < ArelHelpers::QueryBuilder
  def initialize(query = nil)
    # whatever you want your initial query to be
    super(query || event.unscoped)
  end

  def with_action(action)
    reflect(
      query.where(event[:action].matches("%#{action}%"))
    )
  end

  def with_admin_events_by(admin_id)
    reflect(query.joins(:admin).where(event[:admin_id].eq(admin_id)).distinct)
  end
  
  def with_company_events_by(company_admin_id)
    reflect( query.joins(:company_admin).where(event[:company_admin_id].eq(company_admin_id))).distinct
  end
  def with_user_events_by(user_id)
    reflect( query.joins(:users).where(event[:user_id].eq(user_id))).distinct
  end

  def since_yesterday
    reflect(query.where(event[:created_at].gteq(Date.yesterday)))
  end

  private
  def timesheet
    Timesheet
  end
  def admin
    Admin
  end
    
  def company_admin
    CompanyAdmin
  end
  def user
    User
  end

  def event
    Event
  end
end