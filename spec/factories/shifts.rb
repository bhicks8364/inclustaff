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

FactoryGirl.define do
 	factory :shift do
 	    job
 	    time_in { 2.hours.ago }
 	    time_out { nil }
 	    employee
 	    
 	    factory :off_shift do
 	        time_in { 2.hours.ago }
            state "clocked_out"
            time_out { Time.current }
        end
  end

end
    # t.datetime "time_in"
    # t.datetime "time_out"
    # t.integer  "employee_id"
    # t.datetime "created_at",   null: false
    # t.datetime "updated_at",   null: false
    # t.decimal  "time_worked"
    # t.integer  "job_id"
    # t.string   "state"
    # t.decimal  "earnings"
    # t.integer  "timesheet_id"
