class AddReadAtToComments < ActiveRecord::Migration
  def change
    add_column :comments, :read_at, :datetime
  end
end
