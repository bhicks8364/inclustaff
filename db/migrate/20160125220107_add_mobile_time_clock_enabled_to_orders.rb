class AddMobileTimeClockEnabledToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :mobile_time_clock_enabled, :boolean, default: false
  end
end
