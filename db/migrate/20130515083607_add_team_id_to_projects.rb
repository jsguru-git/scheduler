class AddTeamIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :team_id, :integer
    add_column :projects, :business_owner_id, :integer
    
    add_index :projects, [:team_id]
    add_index :projects, [:business_owner_id]
  end
end
