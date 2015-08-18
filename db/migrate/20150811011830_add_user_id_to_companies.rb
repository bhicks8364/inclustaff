class AddUserIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :user_id, :integer
    add_index :companies, :user_id
    add_column :timesheets, :approved_by, :integer
  end
end
