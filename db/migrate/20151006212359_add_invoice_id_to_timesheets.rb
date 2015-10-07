class AddInvoiceIdToTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :invoice_id, :integer
    add_index :timesheets, :invoice_id
  end
end
