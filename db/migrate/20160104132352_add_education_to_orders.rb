class AddEducationToOrders < ActiveRecord::Migration
  def change
    add_column :comments, :notify, :hstore,   default: {}
    add_column :orders, :education, :hstore,   default: {}
    add_column :orders, :requirements, :hstore,   default: {}
    add_column :orders, :industry, :string
    add_column :orders, :published_at, :datetime
    add_column :orders, :published_by, :integer
    add_index :orders, :published_by
    add_index :orders, :industry
    add_column :orders, :expires_at, :datetime
    remove_column :orders, :pay_range, :string
  end
end
