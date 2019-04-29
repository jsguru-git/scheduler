class CreateQuoteActivities < ActiveRecord::Migration
  def change
    create_table :quote_activities do |t|
      t.integer :quote_id, :rate_card_id
      t.string :name
      t.integer :estimate_scale, :default => 1
      t.integer :min_estimated_minutes, :max_estimated_minutes, :min_amount_cents, :max_amount_cents, :position
      t.timestamps
    end
    add_index :quote_activities, [:quote_id]
    add_index :quote_activities, [:rate_card_id]
        
    execute("ALTER TABLE quote_activities CHANGE min_estimated_minutes min_estimated_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE quote_activities CHANGE max_estimated_minutes max_estimated_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE quote_activities CHANGE min_amount_cents min_amount_cents BIGINT DEFAULT 0")
    execute("ALTER TABLE quote_activities CHANGE max_amount_cents max_amount_cents BIGINT DEFAULT 0")
  end
end
