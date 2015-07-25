class RemoveCompanyIdFromShifts < ActiveRecord::Migration
  def change
    remove_column :shifts, :company_id
    add_column :employees, :phone_number, :string
  end
end
