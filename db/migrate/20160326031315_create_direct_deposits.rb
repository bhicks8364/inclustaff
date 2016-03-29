class CreateDirectDeposits < ActiveRecord::Migration
  def change
    create_table :direct_deposits do |t|
      t.integer :employee_id
      t.string :account_number
      t.string :routing_number
      t.string :acct_confirmation
      t.string :admin_id
      t.datetime :effective_date
      t.string :account_type, default: "Checking"

      t.timestamps null: false
    end
    add_index :direct_deposits, :employee_id
  end
end
