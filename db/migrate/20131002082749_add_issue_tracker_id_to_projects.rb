class AddIssueTrackerIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :issue_tracker_id, :string
  end
end
