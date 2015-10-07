class OrderQueryBuilder < ArelHelpers::QueryBuilder
  def initialize(query = nil)
    # whatever you want your initial query to be
    super(query || job_order.unscoped)
  end

  def with_title_matching(title)
    reflect(
      query.where(job_order[:title].matches("%#{title}%"))
    )
  end

  def with_comments_by(names)
    reflect(
      query
        .joins(:comments => :company)
        .where(company[:id].eq(names))
    )
  end

  def since_yesterday
    reflect(
      query.where(job_order[:created_at].gteq(Date.yesterday))
    )
  end

  private

  def company
    Company
  end

  def job_order
    Order
  end
end