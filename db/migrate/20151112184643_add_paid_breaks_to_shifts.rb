class AddPaidBreaksToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :paid_breaks, :boolean, default: false
    add_column :shifts, :pay_rate, :decimal
  end
end
