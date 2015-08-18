class AddIpToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :in_ip, :string
    add_column :shifts, :out_ip, :string
    add_column :timesheets, :state, :string
  end
end
