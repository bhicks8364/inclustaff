class AddDeletedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :datetime
    add_column :employees, :deleted_at, :datetime
    add_column :timesheets, :deleted_at, :datetime
    add_column :shifts, :deleted_at, :datetime
    add_column :orders, :deleted_at, :datetime
    add_column :jobs, :deleted_at, :datetime
    add_column :users, :can_edit, :boolean
    add_column :orders, :manager_id, :integer
    add_index :orders, :manager_id
    add_index :users, :deleted_at
    add_index :orders, :deleted_at
    add_index :employees, :deleted_at
    add_index :shifts, :deleted_at
    add_index :jobs, :deleted_at
    add_index :timesheets, :deleted_at
    
  end
end
