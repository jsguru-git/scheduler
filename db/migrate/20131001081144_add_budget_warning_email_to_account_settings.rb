class AddBudgetWarningEmailToAccountSettings < ActiveRecord::Migration
  def change
    add_column :account_settings, :budget_warning_email, :string
  end
end
