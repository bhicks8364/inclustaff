class AddFieldsToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :address, :string
    add_column :agencies, :city, :string
    add_column :agencies, :state, :string
    add_column :agencies, :zipcode, :string
    add_column :agencies, :phone_number, :string
    add_column :agencies, :free_trial, :boolean
    add_column :agencies, :contact_name, :string
    add_column :agencies, :contact_email, :string
    add_column :agencies, :contact_id, :integer
    add_index :agencies, :contact_id
    add_column :orders, :bwc_code, :string
    add_column :employees, :desired_job_type, :string
    add_column :employees, :desired_shift, :string
  end
end
