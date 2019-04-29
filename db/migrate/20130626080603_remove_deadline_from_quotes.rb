class RemoveDeadlineFromQuotes < ActiveRecord::Migration
  def up
    remove_column :quotes, :deadline_at
  end

  def down
    add_column :quotes, :deadline_at, :date
  end
end
