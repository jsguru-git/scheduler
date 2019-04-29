class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
        t.integer :project_id
        t.string :name
        t.text :description
        t.timestamps
    end
    add_index :features, [:project_id]
  end
end
