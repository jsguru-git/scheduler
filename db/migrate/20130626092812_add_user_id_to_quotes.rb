class AddUserIdToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :user_id, :integer
    add_index :quotes, [:user_id]
  end
end
