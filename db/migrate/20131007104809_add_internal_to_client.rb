class AddInternalToClient < ActiveRecord::Migration
  def change
    add_column :clients, :internal, :boolean, default: false
  end
end
