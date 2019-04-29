class ChangeCostsInQuotes < ActiveRecord::Migration
  
  
  def change
    remove_column :quotes, :total_min_cost
    remove_column :quotes, :total_max_cost
    remove_column :quotes, :total_avg_cost
    
    add_column :quotes, :cents_total_min_cost, :integer
    add_column :quotes, :cents_total_max_cost, :integer
    add_column :quotes, :cents_total_avg_cost, :integer
  end


end
