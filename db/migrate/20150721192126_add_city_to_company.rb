class AddCityToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :city, :string
    add_column :employees, :email, :string
    add_column :employees, :ssn, :string
    add_column :shifts, :time_worked, :decimal
    add_column :companies, :balance, :decimal
    add_column :shifts, :company_id, :integer
    add_index :shifts, :company_id
    add_index :employees, :email
  end
end
