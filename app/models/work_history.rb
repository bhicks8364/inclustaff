# == Schema Information
#
# Table name: work_histories
#
#  id            :integer          not null, primary key
#  employer_name :string
#  start_date    :date
#  end_date      :date
#  title         :string
#  employee_id   :integer
#  description   :text
#  current       :boolean
#  may_contact   :boolean
#  supervisor    :string
#  phone_number  :string
#  pay           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
### TO-DO 
# =>ADD :verified (for reference checks)
# =>
#
#
class WorkHistory < ActiveRecord::Base
    belongs_to :employee
    include ArelHelpers::ArelTable
    include ArelHelpers::JoinAssociation
    acts_as_taggable
    validates :start_date,  presence: true
    validates :end_date, presence: true, if: :not_current?
    after_save :set_employee_tags
    before_save :set_listed_skills
    before_save :set_end_date, if: :current?
    
    def title_pay
        "#{title} - $#{pay}"
    end
   
    def words
        @words ||= begin
            regex = /([\w]+)/
            description.scan(regex).flatten
        end
        
    end
    
    def listed_skills
        @listed_skills ||= Skill.where(name: words)
    end
    def listed_tags
        @listed_tags ||= ActsAsTaggableOn::Tag.where(name: words).pluck(:name)
    end
   
    
    def matching_orders
         @matching_orders ||= Order.needs_attention.tagged_with([employee.tag_list], :any => true)
    end
    
    def set_listed_skills
        self.tag_list.add(@listed_tags)
    end
    def set_employee_tags
        employee.set_work_tags!
    end
    
    private
    def not_current?
        !current?
    end
    def set_end_date
        self.end_date = Date.today
    end
   
    
end
