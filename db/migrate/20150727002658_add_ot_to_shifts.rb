class AddOtToShifts < ActiveRecord::Migration
  def change
    add_column :companies, :phone_number, :string
    add_column :shifts, :ot_hours, :decimal
    add_column :shifts, :earnings, :decimal

  end
end
