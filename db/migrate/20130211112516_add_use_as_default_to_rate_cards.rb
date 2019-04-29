class AddUseAsDefaultToRateCards < ActiveRecord::Migration
  def change
    add_column :rate_cards, :default_card, :boolean, :default => false
  end
end
