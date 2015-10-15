class ChangeShiftsToAccteptArrays < ActiveRecord::Migration
  def change
    remove_column :shifts, :break_in, :datetime
    remove_column :shifts, :break_out, :datetime
    add_column :shifts, :break_in, :datetime, array: true
    add_column :shifts, :break_out, :datetime, array: true
  end
end
