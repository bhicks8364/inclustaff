class AddManagerToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :account_manager_id, :integer
    add_index :orders, :account_manager_id
  end
end
