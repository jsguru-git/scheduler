class AddIndexsToUserNames < ActiveRecord::Migration
  def change
      remove_index :users, [:account_id]
      add_index :users, [:account_id, :firstname, :lastname]
  end
end
