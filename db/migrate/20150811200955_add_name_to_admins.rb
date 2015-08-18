class AddNameToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :first_name, :string
    add_column :admins, :last_name, :string
    add_column :admins, :company_id, :integer
    add_index :admins, :company_id
  end
end
