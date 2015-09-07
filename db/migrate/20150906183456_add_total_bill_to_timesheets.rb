class AddTotalBillToTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :total_bill, :decimal
  end
end
