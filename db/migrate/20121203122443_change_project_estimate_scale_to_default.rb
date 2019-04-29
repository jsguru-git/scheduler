class ChangeProjectEstimateScaleToDefault < ActiveRecord::Migration
  def change
    remove_column :projects, :estimate_scale
    add_column :projects, :estimate_scale, :integer, :default => 0
  end

end
