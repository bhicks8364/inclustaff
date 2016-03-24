class CreateAdjustments < ActiveRecord::Migration
  def change
    create_table :adjustments do |t|
      t.integer :timesheet_id
      t.string :adj_type
      t.decimal :amount, default: 0
      t.decimal :pay_rate
      t.decimal :bill_rate
      t.decimal :hours, default: 0
      t.boolean :taxable, default: false
      t.integer :entered_by

      t.timestamps null: false
    end
    add_index :adjustments, :timesheet_id
  end
end
