class AddUserNameToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :user_name, :string
  end
end
