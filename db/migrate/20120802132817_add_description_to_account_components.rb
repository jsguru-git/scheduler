class AddDescriptionToAccountComponents < ActiveRecord::Migration
  def change
    add_column :account_components, :description, :text
  end
end
