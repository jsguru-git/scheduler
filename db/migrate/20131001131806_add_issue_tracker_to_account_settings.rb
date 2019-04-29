class AddIssueTrackerToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :issue_tracker_username, :text
    add_column :account_settings, :issue_tracker_password, :text
    add_column :account_settings, :issue_tracker_url, :text
  end
end
