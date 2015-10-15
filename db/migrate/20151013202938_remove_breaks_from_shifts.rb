class RemoveBreaksFromShifts < ActiveRecord::Migration
  def change
    remove_column :shifts, :breaks, :hstore
    remove_column :jobs, :pay_types, :hstore
    add_column :jobs, :pay_types, :text, array: true
    add_column :shifts, :breaks, :text, array: true
    add_index :shifts, :breaks
    add_index :jobs, :pay_types
  end
end
