class AddIncludeInQuoteToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :included_in_quote, :boolean, :default => true
  end
end
