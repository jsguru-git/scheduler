class CreateRateCards < ActiveRecord::Migration
    
    
    #
    #
    def change
        create_table :rate_cards do |t|
            t.string :service_type
            t.integer :daily_cost_cents
            t.integer :account_id
            t.timestamps
        end
        
        add_index :rate_cards, [:account_id]
    end
    
    
end
