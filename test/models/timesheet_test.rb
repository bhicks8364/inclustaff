# == Schema Information
#
# Table name: timesheets
#
#  id           :integer          not null, primary key
#  week         :integer
#  job_id       :integer
#  reg_hours    :decimal(, )
#  ot_hours     :decimal(, )
#  gross_pay    :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#  state        :string
#  approved_by  :integer
#  shifts_count :integer
#

require 'test_helper'

class TimesheetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
