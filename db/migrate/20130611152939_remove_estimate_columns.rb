class RemoveEstimateColumns < ActiveRecord::Migration
  def up
    remove_column :features, :min_estimated_minutes
    remove_column :features, :max_estimated_minutes
    remove_column :features, :estimate_scale
    remove_column :features, :position
    remove_column :features, :included_in_quote
    remove_column :features, :override_min_estimated_minutes
    remove_column :features, :override_max_estimated_minutes
    remove_column :features, :override_estimate_scale
    
    remove_column :projects, :min_estimated_minutes
    remove_column :projects, :max_estimated_minutes
    remove_column :projects, :estimate_scale
    
    remove_column :tasks, :min_estimated_minutes
    #remove_column :tasks, :max_estimated_minutes
    #remove_column :tasks, :estimate_scale
    remove_column :tasks, :included_in_quote
    remove_column :tasks, :override_min_estimated_minutes
    remove_column :tasks, :override_max_estimated_minutes
    remove_column :tasks, :override_estimate_scale
  end

  def down
  end
end
