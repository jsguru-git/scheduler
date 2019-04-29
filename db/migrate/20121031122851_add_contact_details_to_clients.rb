class AddContactDetailsToClients < ActiveRecord::Migration
  def change
      add_column :clients, :address, :text
      add_column :clients, :zipcode, :string
      add_column :clients, :phone, :string
      add_column :clients, :email, :string
      add_column :clients, :fax, :string
  end
end
