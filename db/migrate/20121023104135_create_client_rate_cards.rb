class CreateClientRateCards < ActiveRecord::Migration
    def change
        create_table :client_rate_cards do |t|
            t.integer :daily_cost_cents, :client_id, :rate_card_id
            t.timestamps
        end
        
        add_index :client_rate_cards, [:client_id, :rate_card_id]
        add_index :client_rate_cards, [:rate_card_id, :client_id]
    end
end
