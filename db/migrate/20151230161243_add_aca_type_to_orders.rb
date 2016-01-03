class AddAcaTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :aca_type, :string
    add_column :jobs, :vacation, :hstore
    
  end
end
