class AddActiveToJobs < ActiveRecord::Migration
  def change
    add_column :shifts, :state, :string
    add_column :jobs, :active, :boolean
  end
end
