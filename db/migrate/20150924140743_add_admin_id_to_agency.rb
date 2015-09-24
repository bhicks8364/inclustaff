class AddAdminIdToAgency < ActiveRecord::Migration
  def change
    add_column :agencies, :admin_id, :integer
    add_index :agencies, :admin_id
    add_column :agencies, :subdomain, :string
    add_index :agencies, :subdomain
  end
end
