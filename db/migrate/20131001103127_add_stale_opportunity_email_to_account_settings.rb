class AddStaleOpportunityEmailToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :stale_opportunity_email, :string
  end
end
