class AddDiscountToQuoteActivities < ActiveRecord::Migration
  def change
    add_column :quote_activities, :discount_percentage, :decimal, :precision => 10, :scale => 2, :default => 0
  end
end