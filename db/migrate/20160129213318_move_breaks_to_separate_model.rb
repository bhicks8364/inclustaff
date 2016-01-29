class MoveBreaksToSeparateModel < ActiveRecord::Migration
  def change
    remove_column :shifts, :breaks
    remove_column :shifts, :break_in
    remove_column :shifts, :break_out
  end
end
