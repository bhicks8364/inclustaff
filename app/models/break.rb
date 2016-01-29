# == Schema Information
#
# Table name: breaks
#
#  id         :integer          not null, primary key
#  shift_id   :integer
#  time_in    :datetime
#  time_out   :datetime
#  duration   :decimal(, )
#  paid       :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Break < ActiveRecord::Base
  belongs_to :shift

  before_create :set_paid
  before_save :set_duration

  def set_paid
    self.paid = shift.paid_breaks
    true # Continue processing
  end

  def set_duration
    self.duration = TimeDifference.between(time_in, time_out).in_hours if time_out_changed?
  end
end
