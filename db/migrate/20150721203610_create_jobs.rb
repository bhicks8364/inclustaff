class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.belongs_to :employee
      t.string :title
      t.string :description
      t.date :start_date
      t.decimal :pay_rate
      t.date :end_date

      t.timestamps null: false
    end
  end
end
