class RemoveHstoreFromTimesheets < ActiveRecord::Migration
  def change
    remove_column :timesheets, :adjustments, :hstore
    add_column :timesheets, :reg_bill_rate, :decimal
    add_column :timesheets, :ot_bill_rate, :decimal
  end
end
