class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :iso_code
      t.decimal :exchange_rate, :precision => 10, :scale => 6
      t.timestamps
    end
    add_index :currencies, [:iso_code]
  end
end
