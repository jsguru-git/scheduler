class AddFeatureIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :feature_id, :integer
    add_index :tasks, [:feature_id]
  end
end
