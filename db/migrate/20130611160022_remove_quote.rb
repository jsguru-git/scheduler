class RemoveQuote < ActiveRecord::Migration
  def up
    drop_table :quotes
  end

  def down
  end
end
