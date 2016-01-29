class CreateBreaks < ActiveRecord::Migration
  def change
    create_table :breaks do |t|
      t.integer :shift_id
      t.datetime :time_in
      t.datetime :time_out
      t.decimal :duration
      t.boolean :paid

      t.timestamps null: false
    end
  end
end
