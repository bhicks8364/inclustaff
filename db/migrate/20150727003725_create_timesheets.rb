class CreateTimesheets < ActiveRecord::Migration
  def change
    create_table :timesheets do |t|
      t.integer :week
      t.integer :job_id
      t.decimal :reg_hours
      t.decimal :ot_hours
      t.decimal :gross_pay
      

      t.timestamps null: false
    end
    add_index :timesheets, :job_id
  end
end
