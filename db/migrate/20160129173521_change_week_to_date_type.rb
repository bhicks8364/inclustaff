class ChangeWeekToDateType < ActiveRecord::Migration
  def change
    remove_column :shifts, :week
    add_column :shifts, :week, :date

    remove_column :timesheets, :week
    add_column :timesheets, :week, :date
  end
end
