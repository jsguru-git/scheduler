class AddClientIdToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :client_id, :integer
  end
end
