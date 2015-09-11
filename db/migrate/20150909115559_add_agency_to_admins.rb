class AddAgencyToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :agency_id, :integer
  end
end
