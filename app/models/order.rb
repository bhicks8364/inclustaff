# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  company_id    :integer
#  pay_range     :string
#  notes         :text
#  number_needed :integer
#  needed_by     :datetime
#  urgent        :boolean
#  active        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string
#

class Order < ActiveRecord::Base
  has_many :jobs, inverse_of: :order
  has_many :employees, :through => :jobs
  belongs_to :company, inverse_of: :orders
  
  validates_associated :company
  
  scope :active, -> { where(active: true)}
  scope :urgent, -> { where(urgent: true)}
    
    def company_name
      if self.company
        self.company.name
      else
        "Company Unavailable"
      end
    end
    
  def needs_attention?
    if self.jobs && self.active
      if self.number_needed > self.jobs.count 
        true
      else
        false
      end
    end
  end
  









end
