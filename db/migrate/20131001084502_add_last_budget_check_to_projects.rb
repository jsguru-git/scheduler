class AddLastBudgetCheckToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :last_budget_check, :decimal, :precision => 11, :scale => 2, :default => 0
  end
end
