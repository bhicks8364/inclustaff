class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.datetime :time_in
      t.datetime :time_out
      t.integer :employee_id

      t.timestamps null: false
    end
  end
end
