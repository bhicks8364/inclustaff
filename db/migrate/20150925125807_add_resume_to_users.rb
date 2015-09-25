class AddResumeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :resume_id, :integer
    add_index :users, :resume_id
  end
end
