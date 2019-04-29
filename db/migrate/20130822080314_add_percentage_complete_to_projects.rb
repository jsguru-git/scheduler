class AddPercentageCompleteToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :percentage_complete, :integer, :default => 0
  end
end
