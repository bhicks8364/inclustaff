class AddMarkUpToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :mark_up, :decimal
  end
end
