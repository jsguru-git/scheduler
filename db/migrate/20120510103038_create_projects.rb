class CreateProjects < ActiveRecord::Migration
    def change
        create_table :projects do |t|
            t.string  :name
            t.text    :description
            t.boolean :archived, :default => false
            t.integer :account_id, :client_id
            t.timestamps
        end
        
        add_index :projects, [:account_id, :client_id]
        add_index :projects, [:client_id]
    end
end
