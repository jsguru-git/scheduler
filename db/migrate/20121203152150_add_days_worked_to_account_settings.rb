class AddDaysWorkedToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :working_days, :string
  end
end
