class AddProjectStatusOverriddenToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :project_status_overridden, :boolean
  end
end
