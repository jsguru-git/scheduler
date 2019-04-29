class AddProjectStatusToProject < ActiveRecord::Migration
  def change
    add_column :projects, :project_status, :string
  end
end
