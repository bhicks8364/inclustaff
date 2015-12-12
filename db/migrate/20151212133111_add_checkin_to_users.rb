class AddCheckinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :checked_in_at, :datetime
    add_column :company_admins, :name, :string
    add_column :admins, :name, :string
    add_column :users, :name, :string
  end
end
