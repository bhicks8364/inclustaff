# == Schema Information
#
# Table name: direct_deposits
#
#  id                :integer          not null, primary key
#  employee_id       :integer
#  account_number    :string
#  routing_number    :string
#  acct_confirmation :string
#  admin_id          :string
#  effective_date    :datetime
#  account_type      :string           default("Checking")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_direct_deposits_on_employee_id  (employee_id)
#

class DirectDeposit < ActiveRecord::Base
    belongs_to :employee
    belongs_to :admin
    
    validates :routing_number, presence: true, length: { is: 9 }
    validates :account_number, confirmation: true
    validates :account_number_confirmation, presence: true
end
