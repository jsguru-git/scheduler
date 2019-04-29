class AddArchivedToClients < ActiveRecord::Migration
  def change
    add_column :clients, :archived, :boolean, :default => false
  end
end
