class CreateRateCardProjects < ActiveRecord::Migration
  def change
    create_table :rate_card_projects do |t|
      t.integer :rate_card_id, :project_id
      t.integer :percentage, :default => 0
      t.timestamps
    end
    add_index :rate_card_projects, [:rate_card_id, :project_id], :name => 'rate_card_projects_in1'
    add_index :rate_card_projects, [:project_id, :rate_card_id], :name => 'rate_card_projects_in2'
  end
end
