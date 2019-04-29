class AddDeadlineAtToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :deadline_at, :date
  end
end
