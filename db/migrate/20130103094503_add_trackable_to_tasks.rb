class AddTrackableToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :trackable, :boolean, :default => true
  end
end
