class AddQuoteActivityIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :quote_activity_id, :integer
  end
end
