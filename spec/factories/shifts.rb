# == Schema Information
#
# Table name: shifts
#
#  id             :integer          not null, primary key
#  time_in        :datetime
#  time_out       :datetime
#  employee_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  time_worked    :decimal(, )
#  job_id         :integer
#  state          :string
#  earnings       :decimal(, )
#  timesheet_id   :integer
#  deleted_at     :datetime
#  in_ip          :string
#  out_ip         :string
#  note           :text
#  needs_adj      :boolean
#  break_duration :decimal(, )
#  paid_breaks    :boolean          default(FALSE)
#  pay_rate       :decimal(, )
#  latitude       :float
#  longitude      :float
#  week           :date
#
# Indexes
#
#  index_shifts_on_deleted_at    (deleted_at)
#  index_shifts_on_job_id        (job_id)
#  index_shifts_on_timesheet_id  (timesheet_id)
#

FactoryGirl.define do
   
 	factory :shift do
 	    job_id 1
 	    time_in { 2.hours.ago }
 	    time_out { nil }
 	    employee_id 1
 	    
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
