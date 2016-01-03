class AddLatitudeAndLongitudeToAdmin < ActiveRecord::Migration
  def change
    add_column :agencies, :preferences, :hstore, default: {}
    add_column :companies, :preferences, :hstore, default: {}
    add_column :admins, :latitude, :float
    add_column :admins, :longitude, :float
    add_column :company_admins, :latitude, :float
    add_column :company_admins, :longitude, :float
    add_column :timesheets, :total_hours, :decimal
  end
end
