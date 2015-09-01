class AddBreakToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :week, :integer
    add_column :shifts, :break_in, :datetime
    add_column :shifts, :break_out, :datetime
    add_column :shifts, :note, :text
    add_column :shifts, :needs_adj, :boolean
    add_index :shifts, :week
  end
end
