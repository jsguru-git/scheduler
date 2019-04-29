class AddColumnsToAccountSettings < ActiveRecord::Migration
    def change
        remove_column :account_settings, :lunch_task_id
        
        add_column :account_settings, :common_project_id, :integer
        add_index :account_settings, [:common_project_id]
        add_column :tasks, :count_towards_time_worked, :boolean, :default => true
   end
end
