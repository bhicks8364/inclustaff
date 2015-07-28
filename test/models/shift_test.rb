# == Schema Information
#
# Table name: shifts
#
#  id           :integer          not null, primary key
#  time_in      :datetime
#  time_out     :datetime
#  employee_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  time_worked  :decimal(, )
#  job_id       :integer
#  state        :string
#  earnings     :decimal(, )
#  timesheet_id :integer
#

require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
