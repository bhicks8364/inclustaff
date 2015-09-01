class AddAssignedToEmployee < ActiveRecord::Migration
  def change
    add_column :employees, :assigned, :boolean
    add_column :jobs, :recruiter_id, :integer
    add_index :jobs, :recruiter_id
  end
end
