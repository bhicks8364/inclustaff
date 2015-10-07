class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :company_id
      t.integer :agency_id
      t.integer :week
      t.datetime :due_by
      t.boolean :paid
      t.decimal :total
      t.decimal :amt_paid
      t.datetime :date_paid

      t.timestamps null: false
    end
    add_index :invoices, :company_id
    add_index :invoices, :agency_id
  end
end
