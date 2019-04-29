class CreateTeamUsers < ActiveRecord::Migration
    def change
        create_table :team_users do |t|
            t.integer :team_id, :user_id
            t.timestamps
        end
        add_index :team_users, [:team_id, :user_id]
        add_index :team_users, [:user_id, :team_id]
    end
end
