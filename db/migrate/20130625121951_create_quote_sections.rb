class CreateQuoteSections < ActiveRecord::Migration
  def change
    create_table :quote_sections do |t|
      t.string :title
      t.text :content
      t.integer :position, :quote_id
      t.boolean :cost_section, :default => false
      t.timestamps
    end
    add_index :quote_sections, [:quote_id]
  end
end
