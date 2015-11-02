class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :commentable_type
      t.integer :commentable_id
      t.integer :admin_id
      t.integer :company_admin_id
      t.integer :user_id
      t.text :body

      t.timestamps null: false
    end
    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :admin_id
    add_index :comments, :company_admin_id
    add_index :comments, :user_id
  end
end
