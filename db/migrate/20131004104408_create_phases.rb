class CreatePhases < ActiveRecord::Migration
  def change
    create_table :phases do |t|
      t.string :name
      t.integer :account_id

      t.timestamps
    end

    add_column :projects, :phase_id, :integer
  end
end
