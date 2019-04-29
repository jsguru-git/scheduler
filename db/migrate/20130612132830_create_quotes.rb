class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.integer :project_id
      t.string :title, :currency, :summary
      t.text :further_information, :disclaimer
      t.decimal :vat_rate, :precision => 10, :scale => 2
      t.decimal :discount_percentage, :precision => 10, :scale => 2
      t.boolean :new_quote, :default => 1
      t.integer :quote_id
      t.timestamps
    end
    add_index :quotes, [:project_id]
    add_index :quotes, [:quote_id]
  end
end
