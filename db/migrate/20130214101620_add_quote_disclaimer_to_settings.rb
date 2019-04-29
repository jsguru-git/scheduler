class AddQuoteDisclaimerToSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :quote_further_information, :text
    add_column :account_settings, :quote_disclaimer, :text
  end
end
