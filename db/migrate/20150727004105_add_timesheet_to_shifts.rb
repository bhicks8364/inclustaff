class AddTimesheetToShifts < ActiveRecord::Migration
  def change
    remove_column :shifts, :ot_hours
    add_column :shifts, :timesheet_id, :integer
    add_index :shifts, :timesheet_id
  end
end
