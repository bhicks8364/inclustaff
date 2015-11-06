class AddApprovedByTypeToTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :approved_by_type, :string
    add_index :timesheets, :approved_by_type
  end
end
