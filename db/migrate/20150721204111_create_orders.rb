class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :company
      t.string :pay_range
      t.text :notes
      t.integer :number_needed
      t.datetime :needed_by
      t.boolean :urgent
      t.boolean :active

      t.timestamps null: false
    end
  end
end
