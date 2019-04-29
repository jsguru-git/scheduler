class AddLastSavedByIdToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :last_saved_by_id, :integer
    add_index :quotes, [:last_saved_by_id]
  end
end
