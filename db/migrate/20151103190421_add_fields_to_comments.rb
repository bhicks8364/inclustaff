class AddFieldsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :action, :string
    add_index :comments, :action
    add_column :comments, :recipient_id, :integer
    add_index :comments, :recipient_id
    add_column :comments, :recipient_type, :string
    add_index :comments, :recipient_type
    add_column :comments, :alert, :boolean
  end
end
