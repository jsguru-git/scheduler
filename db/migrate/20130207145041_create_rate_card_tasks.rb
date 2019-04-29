class CreateRateCardTasks < ActiveRecord::Migration
  def change
    create_table :rate_card_tasks do |t|
      t.integer :rate_card_id, :task_id
      t.integer :percentage, :default => 0
      t.timestamps
    end
    add_index :rate_card_tasks, [:rate_card_id, :task_id], :name => 'rate_card_tasks_in1'
    add_index :rate_card_tasks, [:task_id, :rate_card_id], :name => 'rate_card_tasks_in2'
  end
end
