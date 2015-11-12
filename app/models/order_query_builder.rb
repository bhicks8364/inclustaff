# class OrderQueryBuilder < ArelHelpers::QueryBuilder
#   def initialize(query = nil)
#     # whatever you want your initial query to be
#     super(query || job_order.unscoped)
#   end

#   # def with_skills_matching(skills)
#   #   reflect(
#   #     query.where(job_order[:title].matches("%#{title}%"))
#   #   )
#   # end

#   def with_skills_matching(skills)
#     reflect(
#       query
#         .joins(:skills)
#         .where(Skill[:name].eq(skill))
#     )
#   end

#   def since_yesterday
#     reflect(
#       query.where(job_order[:created_at].gteq(Date.yesterday))
#     )
#   end

#   private

#   def skill
#     Skill
#   end

#   def job_order
#     Order
#   end
# end