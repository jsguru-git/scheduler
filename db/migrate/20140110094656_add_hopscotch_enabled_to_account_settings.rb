class AddHopscotchEnabledToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :hopscotch_enabled, :boolean, default: false
  end
end
