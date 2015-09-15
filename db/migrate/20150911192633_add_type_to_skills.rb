class AddTypeToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :skillable_type, :string
    add_column :skills, :skillable_id, :integer
    remove_column :skills, :order_id, :integer
  end
end
