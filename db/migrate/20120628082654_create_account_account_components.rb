class CreateAccountAccountComponents < ActiveRecord::Migration
  def change
    create_table :account_account_components do |t|
        t.integer :account_id, :account_component_id
        t.timestamps
    end
    
    add_index :account_account_components, [:account_id, :account_component_id], :name => 'account_account_components_1'
	add_index :account_account_components, [:account_component_id, :account_id], :name => 'account_account_components_2'
  end
end
