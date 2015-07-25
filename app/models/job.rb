# == Schema Information
#
# Table name: jobs
#
#  id          :integer          not null, primary key
#  employee_id :integer
#  order_id    :integer
#  title       :string
#  description :string
#  start_date  :date
#  pay_rate    :decimal(, )
#  end_date    :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active      :boolean
#

class Job < ActiveRecord::Base
    belongs_to :employee
    belongs_to :order
    has_many :shifts, inverse_of: :job
    
    accepts_nested_attributes_for :employee
    
    include ArelHelpers::ArelTable
    
    # VALIDATIONS
    validates_associated :employee
    validates_associated :order
    validates :employee_id,  presence: true
    validates :order_id,  presence: true
    validates :title,  presence: true, length: { maximum: 50 }
    
    # CALLBACKS
    after_initialize :defaults

    # SCOPES
    scope :active, -> { where(active: true)}
    
    
    def company
        self.order.company
    end
    

    def defaults
        self.active = true if self.active.nil?
        self.end_date = 2115-07-25 if self.end_date.nil?
    end
    
    def current_week_pay
        hours = self.shifts.current_week.sum(:time_worked)
        if hours > 40
            reg_hours = 40
            ot_hours = hours - 40
            ot_rate = self.pay_rate * 1.5
            self.pay_rate * reg_hours + ot_hours * ot_rate
        else
            self.pay_rate * hours
        end
    end
    
    def current_week_hours
        self.shifts.current_week.sum(:time_worked)
    end
    
    def total_hours
        self.shifts.sum(:time_worked)
    end
    
    
    
end
