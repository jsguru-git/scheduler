class AddLogoFingerprintToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :logo_fingerprint, :string
  end
end
