class CreateTeams < ActiveRecord::Migration
    def change
        create_table :teams do |t|
            t.string :name
            t.integer :account_id
            t.timestamps
        end
        add_index :teams, :account_id
    end
end
