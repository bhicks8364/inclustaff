class AddCounterToTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :shifts_count, :integer
    add_column :jobs, :timesheets_count, :integer
    add_column :orders, :jobs_count, :integer
    add_column :shifts, :break_duration, :decimal
  end
end
