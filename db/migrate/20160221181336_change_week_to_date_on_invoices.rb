class ChangeWeekToDateOnInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :week
    add_column :invoices, :week, :date
  end
end
