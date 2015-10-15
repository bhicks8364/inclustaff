class AddHstore < ActiveRecord::Migration

  def change
   
    add_column :jobs, :settings, :hstore
    add_column :timesheets, :adjustments, :hstore
    
  end


end
