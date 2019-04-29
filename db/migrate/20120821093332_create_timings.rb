class CreateTimings < ActiveRecord::Migration
    
    
    #
    #
    def change
        create_table :timings do |t|
            t.integer :user_id, :duration_minutes, :project_id, :task_id
            t.datetime :started_at, :ended_at
            t.boolean :submitted, :default => 0
            t.text    :notes
            t.timestamps
        end
        
        add_index :timings, [:user_id]
        add_index :timings, [:project_id]
        add_index :timings, [:task_id]
    end
    
    
end
