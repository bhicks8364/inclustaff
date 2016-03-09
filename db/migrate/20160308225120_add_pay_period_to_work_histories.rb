class AddPayPeriodToWorkHistories < ActiveRecord::Migration
  def change
    add_column :work_histories, :pay_period, :string
  end
end
