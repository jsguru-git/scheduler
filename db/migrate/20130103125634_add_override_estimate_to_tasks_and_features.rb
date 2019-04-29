class AddOverrideEstimateToTasksAndFeatures < ActiveRecord::Migration
  def change
    add_column :features, :override_min_estimated_minutes, :integer, :default => 0
    add_column :features, :override_max_estimated_minutes, :integer, :default => 0
    add_column :features, :override_estimate_scale, :integer, :default => 0

    add_column :tasks, :override_min_estimated_minutes, :integer, :default => 0
    add_column :tasks, :override_max_estimated_minutes, :integer, :default => 0
    add_column :tasks, :override_estimate_scale, :integer, :default => 0
    
    execute("ALTER TABLE features CHANGE override_min_estimated_minutes override_min_estimated_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE features CHANGE override_max_estimated_minutes override_max_estimated_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE tasks CHANGE override_min_estimated_minutes override_min_estimated_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE tasks CHANGE override_max_estimated_minutes override_max_estimated_minutes BIGINT DEFAULT 0")
  end
end
