class AddExtraCostToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :extra_cost_cents, :integer, :default => 0
    add_column :quotes, :extra_cost_title, :string
  end
end
