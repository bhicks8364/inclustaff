class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.string :name
      t.string :job_title
      t.string :agency_name
      t.string :email
      t.string :agency_size
      t.string :phone_number

      t.timestamps null: false
    end
  end
end
