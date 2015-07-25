class AddOrderIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :order_id, :belongs_to
  end
end
