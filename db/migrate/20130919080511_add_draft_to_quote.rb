class AddDraftToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :draft, :boolean, :default => true
  end
end
