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

class Skill < ActiveRecord::Base
    belongs_to :skillable, polymorphic: true
    
    # searchkick suggest: [:name]
    # def search_data
    #     {
    #       name: name,
    #       subject: subject
    #     }
    # end
    scope :required, -> { where(required: true, skillable_type: "Order")}
    def subject
        skillable.try(:name) || skillable.try(:title)
    end
    
    
    
    scope :job_order, -> { where(skillable_type: "Order")}
    scope :employee, -> { where(skillable_type: "Employee")}
    # scope :employee, -> { where(skillable_type: "Employee")}
    
    # def with_comments_by(usernames)
    #     self.joins(:skillable)
    #         .where(Employee[:username].in(usernames))
        
    # end
    
    
    
end
