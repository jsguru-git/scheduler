class AddDefaultCurrecncyToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :default_currency, :string, :default => 'usd'
  end
end
