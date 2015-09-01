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
#  deleted_at   :datetime
#  in_ip        :string
#  out_ip       :string
#  week         :integer
#  break_in     :datetime
#  break_out    :datetime
#  note         :text
#  needs_adj    :boolean
#

class ShiftSerializer < ActiveModel::Serializer
  attributes :id, :time_in, :time_out, :employee_id, :note
  has_one :employee
  has_one :timesheet
  embed :ids, include: true



end
