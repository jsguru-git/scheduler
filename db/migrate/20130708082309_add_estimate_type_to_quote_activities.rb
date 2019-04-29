class AddEstimateTypeToQuoteActivities < ActiveRecord::Migration
  def change
    add_column :quote_activities, :estimate_type, :integer, :default => 0
  end
end
