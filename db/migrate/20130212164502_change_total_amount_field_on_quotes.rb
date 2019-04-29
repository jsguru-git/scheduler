class ChangeTotalAmountFieldOnQuotes < ActiveRecord::Migration
  def change
    remove_column :quotes, :total_cost
    add_column :quotes, :total_min_cost, :decimal, :precision => 7, :scale => 2
    add_column :quotes, :total_max_cost, :decimal, :precision => 7, :scale => 2
    add_column :quotes, :total_avg_cost, :decimal, :precision => 7, :scale => 2
  end

end
