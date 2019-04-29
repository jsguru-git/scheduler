class AddCurrencyToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :currency, :string
  end
end
