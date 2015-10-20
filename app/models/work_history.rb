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

class WorkHistory < ActiveRecord::Base
    belongs_to :employee
    
    before_save :set_employee_skills
    
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
    
    def employee_skills

        @employee_skills ||= self.employee.skills.where(name: words)
    end
    def listed_skills

        @listed_skills ||= Skill.job_order.where(name: words)
    end
    
    def matching_orders
        listed_skills.job_order
    end
    
    def set_employee_skills
        listed_skills.each do |skill|
            self.employee.skills.find_or_create_by(name: skill.name)
        end
    end
    
end
