class AddPoNumberToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :po_number, :string
  end
end
