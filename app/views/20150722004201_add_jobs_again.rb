class AddJobsAgain < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :employee_id
      t.integer :order_id
      t.string :title
      t.string :description
      t.date :start_date
      t.decimal :pay_rate
      t.date :end_date

      t.timestamps null: false
    end
  end
end