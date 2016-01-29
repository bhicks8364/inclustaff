class FixAvailabilityNameOnEmployees < ActiveRecord::Migration
  def change
    rename_column :employees, :availablity, :availability
  end
end
