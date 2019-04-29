class AddEstimationToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :min_estimated_minutes, :integer, :default => 0
    add_column :features, :max_estimated_minutes, :integer, :default => 0
    add_column :features, :estimate_scale, :integer, :default => 0
    
    execute("ALTER TABLE features CHANGE min_estimated_minutes min_estimated_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE features CHANGE max_estimated_minutes max_estimated_minutes BIGINT DEFAULT 0")
  end
end
