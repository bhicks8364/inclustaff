class OrderQueryBuilder < ArelHelpers::QueryBuilder
  def initialize(query = nil)
    # whatever you want your initial query to be
    super(query || job_order.unscoped)
  end

  def filled
    reflect(
      query
        .joins(:jobs).where(Job[:state].eq("Currently Working"))
    )
  end

  def since_yesterday
    reflect(
      query.where(job_order[:created_at].gteq(Date.yesterday))
    )
  end

  private

  def skill
    Skill
  end

  def job_order
    Order
  end
end