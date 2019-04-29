class AddFileTypeToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :file_type, :string
  end
end
