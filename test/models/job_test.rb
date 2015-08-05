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
#  deleted_at  :datetime
#

require 'test_helper'

class JobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
