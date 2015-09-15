class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :name
      t.integer :order_id
      t.boolean :required, :default => false

      t.timestamps null: false
    end
  end
end
