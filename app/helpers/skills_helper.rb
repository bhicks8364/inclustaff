# == Schema Information
#
# Table name: skills
#
#  id             :integer          not null, primary key
#  name           :string
#  required       :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  skillable_type :string
#  skillable_id   :integer
#

module SkillsHelper
    def skills_popover(skills)
        "<span class='black'><i class='fa fa-wrench fa-lg' data-placement='right' data-toggle='tooltip' title='#{skills.map {|p| p.name.titleize}.join(', ') }'></i></span>".html_safe
    end
end
