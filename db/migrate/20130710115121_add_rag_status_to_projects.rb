class AddRagStatusToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :current_rag_status, :integer, :default => 0
    add_column :projects, :expected_rag_status, :integer, :default => 0
  end
end
