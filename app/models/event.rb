# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  admin_id       :integer
#  action         :string
#  eventable_id   :integer
#  eventable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#

class Event < ActiveRecord::Base
    belongs_to :admin
    belongs_to :user
    belongs_to :eventable, polymorphic: true
    
    scope :admin, -> { where.not(admin_id: nil)}
    scope :employee, -> { where(admin_id: nil)}
    scope :applications, -> { where(action: 'applied')}
    scope :clock_ins, -> { where(action: 'clocked_in')}
    scope :clock_outs, -> { where(action: 'clocked_out')}
    
    def application?
        if self.action == "applied"
            true
        else
            false
        end
    end
    
    def self.mentions(admin_id)
        where(action: "mentioned", eventable_id: admin_id)
    end
    
    def self.employee_events(user_id)
        where(eventable_id: user_id)
    end
    def self.admin_events(admin_id)
        where(eventable_id: admin_id)
    end
    
    
end
