class AddOrderIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :order_id, :integer
  end
end
