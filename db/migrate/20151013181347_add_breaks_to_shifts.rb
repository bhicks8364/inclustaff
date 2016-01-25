class AddBreaksToShifts < ActiveRecord::Migration
  def change
    add_column :jobs, :settings, :hstore
    add_column :timesheets, :adjustments, :hstore

    add_column :shifts, :breaks, :hstore
    add_index :shifts, :breaks
    add_column :jobs, :pay_types, :hstore
    add_index :jobs, :pay_types
  end
end
