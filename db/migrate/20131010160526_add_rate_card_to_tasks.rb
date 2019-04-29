class AddRateCardToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :rate_card_id, :integer
  end
end
