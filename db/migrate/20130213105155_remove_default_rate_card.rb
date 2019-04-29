class RemoveDefaultRateCard < ActiveRecord::Migration
  
  def change
    remove_column :rate_cards, :default_card
  end

end
