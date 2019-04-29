class AddPriorityToAccountComponents < ActiveRecord::Migration
  def change
    add_column :account_components, :priority, :integer
  end
end
