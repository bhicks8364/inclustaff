class AddTimesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shift_start, :datetime
    add_column :orders, :shift_end, :datetime
    add_column :orders, :account_manager_notes, :text
    add_column :orders, :job_description, :text
    add_column :orders, :payroll_code, :string
  end
end
