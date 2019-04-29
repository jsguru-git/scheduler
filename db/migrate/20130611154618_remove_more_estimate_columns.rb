class RemoveMoreEstimateColumns < ActiveRecord::Migration
  def up
    remove_column :tasks, :trackable
    drop_table :rate_card_features
    drop_table :rate_card_projects
    drop_table :rate_card_tasks
  end

  def down
  end
end
