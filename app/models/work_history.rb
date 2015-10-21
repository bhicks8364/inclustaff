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
  
    validates :start_date,  presence: true
    validates :end_date,  presence: true
    
    
    after_save :set_listed_skills
    
    def current?
        self.current == true
    end
    
    def may_contact?
        self.may_contact == true
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
    
    
    def matching_orders
        @matching_orders ||= Skill.job_order.where(name: words)
    end
    
    def set_listed_skills
        listed_skills.each do |skill|
            self.employee.skills.find_or_create_by(name: skill.name)
        end
    end
    # def check_end_date
    #     if self.end_date.nil?
    #         self.end_date = Date.today
    #     end
    # end
    
    
end
