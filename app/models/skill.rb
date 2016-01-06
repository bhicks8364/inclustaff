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
    
    before_save :remove_hashtag, :titleize_name
    after_save :create_tag
    before_destroy :delete_tag
    
    def create_tag
      if skillable.present?
          skillable.tag_list.add(name)
          skillable.save
      end
    end
    
    def delete_tag
      if skillable.present?
        skillable.tag_list.remove(name)
        skillable.save
      end
    end
    # searchkick suggest: [:name]
    # def search_data
    #     {
    #       name: name,
    #       subject: subject
    #     }
    # end
    scope :general, -> { where(skillable_id: nil)}
    scope :required, -> { where(required: true, skillable_type: "Order")}
    scope :additional, -> { where(required: false, skillable_type: "Order")}
    def subject
        skillable.try(:name) || skillable.try(:title)
    end
    
    
    
    scope :job_order, -> { where(skillable_type: "Order")}
    scope :need_skills, -> { job_order.joins(:user).merge(User.unassigned)}
    scope :employee, -> { where(skillable_type: "Employee")}
    # scope :employee, -> { where(skillable_type: "Employee")}
    
    
    
    def employee?
        skillable_type == "Employee"
    end
    def job_order?
        skillable_type == "Order"
    end
    def matching(name)
        where(name: name)
    end
    
    def remove_hashtag
        if self.name.starts_with?("#")
            self.name.delete!("#")
        end
    end
    def titleize_name
      self.name = self.name.titleize
    end
    
    # IMPORT
    def self.assign_from_row(row)
        skill = Skill.general.where(name: row[:name]).first_or_initialize
        skill.assign_attributes row.to_hash.slice(:name)
        skill
    end
    
    
    
    
end
