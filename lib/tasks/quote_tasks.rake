namespace :quote do


  desc "Delete un-used draft quotes"
  task(:delete_draft_quotes => :environment) do
    Quote.delete_old_draft_quotes
  end

end
