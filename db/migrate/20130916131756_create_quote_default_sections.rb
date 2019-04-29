class CreateQuoteDefaultSections < ActiveRecord::Migration
  def change
    create_table :quote_default_sections do |t|
      t.integer :account_id, :position
      t.string :title
      t.text :content
      t.timestamps
    end
    
    add_index :quote_default_sections, [:account_id]
  end
end
