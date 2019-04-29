class AddQuoteStatusToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :quote_status, :integer
  end
end
