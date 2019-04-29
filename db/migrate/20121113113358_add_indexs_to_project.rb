class AddIndexsToProject < ActiveRecord::Migration
  def change
      remove_index :projects, [:account_id, :client_id]
      
      add_index :projects, [:account_id, :name, :client_id]
      add_index :projects, [:account_id, :client_id]
  end
end
