class AddIncludeInQuoteToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :included_in_quote, :boolean, :default => true
  end
end
