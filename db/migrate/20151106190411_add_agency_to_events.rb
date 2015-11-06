class AddAgencyToEvents < ActiveRecord::Migration
  def change
    add_column :events, :agency_id, :integer
    add_index :events, :agency_id
    add_column :events, :company_admin_id, :integer
    add_index :events, :company_admin_id
  end
end
