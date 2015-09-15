class AddMoreInfoToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :dt_req, :string
    add_column :orders, :bg_check, :string
    add_column :orders, :heavy_lifting, :boolean
    add_column :orders, :stwb, :boolean
    add_column :orders, :est_duration, :string
    add_column :orders, :shift, :string
  end
end
