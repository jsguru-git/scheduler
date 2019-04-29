class AddUseAsBigintsToQuote < ActiveRecord::Migration
  def change
    execute("ALTER TABLE quotes CHANGE min_estimate_minutes min_estimate_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE quotes CHANGE max_estimate_minutes max_estimate_minutes BIGINT DEFAULT 0")
    execute("ALTER TABLE quotes CHANGE avg_estimate_minutes avg_estimate_minutes BIGINT DEFAULT 0")
  end
end
