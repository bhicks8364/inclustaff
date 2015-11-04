class AddDnsToEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :dns, :boolean, default: false
  end
end
