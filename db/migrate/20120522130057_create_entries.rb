class CreateEntries < ActiveRecord::Migration
  	def change
    	create_table :entries do |t|
    		t.integer :user_id, :project_id, :account_id
    		t.date :start_date, :end_date
      		t.timestamps
    	end
    	add_index :entries, [:user_id]
    	add_index :entries, [:account_id]
    	add_index :entries, [:project_id]
  	end
end
