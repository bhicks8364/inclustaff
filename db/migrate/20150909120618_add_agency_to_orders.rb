class AddAgencyToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :agency_id, :integer
    add_column :users, :agency_id, :integer
    add_index :users, :agency_id
    add_index :orders, :agency_id
  end
end
