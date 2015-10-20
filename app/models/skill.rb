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
    
    before_save :remove_hashtag
    
    # searchkick suggest: [:name]
    # def search_data
    #     {
    #       name: name,
    #       subject: subject
    #     }
    # end
    scope :required, -> { where(required: true, skillable_type: "Order")}
    scope :additional, -> { where(required: false, skillable_type: "Order")}
    def subject
        skillable.try(:name) || skillable.try(:title)
    end
    
    
    
    scope :job_order, -> { where(skillable_type: "Order")}
    scope :need_skills, -> { job_order.joins(:user).merge(User.unassigned)}
    scope :employee, -> { where(skillable_type: "Employee")}
    scope :open_orders, -> { joins(:skillable).merge(Order.need_attention) }
    # scope :employee, -> { where(skillable_type: "Employee")}
    
    # def with_comments_by(usernames)
    #     self.joins(:skillable)
    #         .where(Employee[:username].in(usernames))
        
    # end
    
    def employee
        skillable if skillable_type == "Employee"
    end
    def job_order
        skillable if skillable_type == "Order"
    end
    
    def remove_hashtag
        if self.name.starts_with?("#")
            self.name.delete!("#")
        end
                
        
    end
    
    
end
