class AddBillAmountToAdjustments < ActiveRecord::Migration
  def change
    add_column :adjustments, :bill_amount, :decimal, default: 0
    add_column :timesheets, :week_ending, :date
    add_column :employees, :exsisting_hours, :decimal, default: 0
    add_column :employees, :aca_hours, :decimal, default: 0
    add_column :employees, :status, :string, default: "New"
  end
end
