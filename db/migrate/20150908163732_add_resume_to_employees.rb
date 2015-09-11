class AddResumeToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :resume_id, :string
  end
end
