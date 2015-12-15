class AddPayToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :min_pay, :decimal
    add_column :orders, :max_pay, :decimal
    add_column :orders, :pay_frequency, :string
  end
end
