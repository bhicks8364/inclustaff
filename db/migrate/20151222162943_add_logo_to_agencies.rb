class AddLogoToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :logo_url, :string
  end
end
