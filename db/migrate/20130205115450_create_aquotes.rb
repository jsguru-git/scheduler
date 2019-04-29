class CreateAquotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.integer :user_id, :project_id, :feature_percentage_complete, :task_percentage_complete, :estimate_scale
      t.integer :min_estimate_minutes, :max_estimate_minutes, :avg_estimate_minutes, :default => 0
      t.string  :quote_currency, :original_currency
      t.decimal :total_cost, :precision => 7, :scale => 2
      t.decimal :exchange_rate, :precision => 10, :scale => 6
      t.boolean :include_min, :include_avg, :default => false
      t.boolean :include_max, :default => true
      t.text :data
      t.timestamps
    end
    add_index :quotes, [:project_id]
  end
end
