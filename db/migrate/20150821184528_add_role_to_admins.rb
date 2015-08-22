class AddRoleToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :role, :string
    add_index :admins, :role
  end
end
