class AddEstimateMinToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :min_estimated_minutes, :integer, :default => 0
    add_column :projects, :max_estimated_minutes, :integer, :default => 0
    add_column :projects, :estimate_scale, :integer, :default => 0
    
    execute("ALTER TABLE projects CHANGE min_estimated_minutes min_estimated_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE projects CHANGE max_estimated_minutes max_estimated_minutes BIGINT DEFAULT 0")
  end
end
