class AddIndexToQuotes < ActiveRecord::Migration
  def change
    add_index :quotes, [:title]
  end
end
