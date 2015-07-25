class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :address
      t.string :state
      t.string :zipcode
      t.string :contact_name
      t.string :contact_email

      t.timestamps null: false
    end
  end
end
