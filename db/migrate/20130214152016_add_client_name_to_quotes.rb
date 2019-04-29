class AddClientNameToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :client_name, :string
    add_index :quotes, [:client_id]
    add_index :quotes, [:user_id]
  end
end
