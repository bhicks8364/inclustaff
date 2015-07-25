class AddJobToShift < ActiveRecord::Migration
  def change
    add_column :shifts, :job_id, :integer
    add_index :shifts, :job_id
  end
end
