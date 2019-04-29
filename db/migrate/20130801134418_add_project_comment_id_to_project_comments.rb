class AddProjectCommentIdToProjectComments < ActiveRecord::Migration
  def change
    add_column :project_comments, :project_comment_id, :integer
    add_index :project_comments, [:project_comment_id]
  end
end
