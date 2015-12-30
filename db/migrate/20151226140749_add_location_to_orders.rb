class AddLocationToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :address, :string
    add_column :orders, :latitude, :float
    add_column :orders, :longitude, :float
    # add_column :users, :address, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :shifts, :latitude, :float
    add_column :shifts, :longitude, :float
  end
end
