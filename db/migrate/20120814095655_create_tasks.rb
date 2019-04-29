class CreateTasks < ActiveRecord::Migration
    def change
        create_table :tasks do |t|
            t.string :name
            t.text :description
            t.integer :project_id, :estimated_minutes
            t.timestamps
        end

        add_index :tasks, [:project_id]
    end
end
