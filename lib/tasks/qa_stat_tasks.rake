namespace :qa_stat do

  desc "Fetch most recent qa data"
  task(:fetch_most_recent_data => :environment) do
    QaStat.pull_lastest_data_from_issue_tracker
  end

end