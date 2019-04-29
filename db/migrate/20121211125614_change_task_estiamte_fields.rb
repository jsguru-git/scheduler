class ChangeTaskEstiamteFields < ActiveRecord::Migration
  def up
    add_column :tasks, :min_estimated_minutes, :integer, :default => 0
    execute("ALTER TABLE tasks CHANGE min_estimated_minutes min_estimated_minutes BIGINT DEFAULT 0")
    
    execute("ALTER TABLE tasks CHANGE estimated_minutes max_estimated_minutes BIGINT DEFAULT 0")
    execute("update tasks set max_estimated_minutes = 0 where max_estimated_minutes IS NULL")
    
    add_column :tasks, :estimate_scale, :integer, :default => 0
  end

  def down
  end
end
