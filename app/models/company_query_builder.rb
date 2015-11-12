# class CompanyQueryBuilder < ArelHelpers::QueryBuilder
#   def initialize(query = nil)
#     # whatever you want your initial query to be
#     super(query || company.unscoped)
#   end

#   def with_name_matching(name)
#     reflect(
#       query.where(company[:name].matches("%#{name}%"))
#     )
#   end

#   def with_comments_by(usernames)
#     reflect(
#       query
#         .joins(:comments => :agency)
#         .where(agency[:username].in(usernames))
#     )
#   end

#   def since_yesterday
#     reflect(
#       query.where(company[:created_at].gteq(Date.yesterday))
#     )
#   end

#   private

#   def agency
#     Agency
#   end

#   def company
#     Company
#   end
# end