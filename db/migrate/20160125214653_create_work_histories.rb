class CreateWorkHistories < ActiveRecord::Migration
  def change
    create_table :work_histories do |t|
      t.integer :employee_id, null: false
      t.string :employer_name
      t.string :title
      t.date :start_date
      t.date :end_date
      t.text :description
      t.boolean :current, default: false
      t.boolean :may_contact, default: false
      t.string :supervisor
      t.string :phone_number
      t.string :pay
    end
  end
end
