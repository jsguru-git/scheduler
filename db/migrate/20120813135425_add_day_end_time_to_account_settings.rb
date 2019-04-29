class AddDayEndTimeToAccountSettings < ActiveRecord::Migration
  def change
    
    add_column :account_settings, :working_day_start_time, :time, :default => '09:00'
    add_column :account_settings, :working_day_end_time, :time, :default => '17:00'
  end
end
