class AddAgencyIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :agency_id, :integer
    add_index :companies, :agency_id
    add_column :companies, :admin_id, :integer
    add_index :companies, :admin_id
  end
end
