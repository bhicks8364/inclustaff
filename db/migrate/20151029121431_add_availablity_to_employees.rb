class AddAvailablityToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :availablity, :hstore
    add_index :employees, :availablity
  end
end
