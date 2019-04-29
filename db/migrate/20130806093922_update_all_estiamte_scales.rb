class UpdateAllEstiamteScales < ActiveRecord::Migration
  def up
    change_column :tasks, :estimate_scale, :integer, :default => 1
    Task.where('estimate_scale = ?', 0).update_all(estimate_scale: 1)
    QuoteActivity.where('estimate_scale = ?', 0).update_all(estimate_scale: 1)
  end

  def down
    change_column :tasks, :estimate_scale, :integer, :default => 0
  end
end
