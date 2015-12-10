class AddReadAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :read_at, :datetime
  end
end
