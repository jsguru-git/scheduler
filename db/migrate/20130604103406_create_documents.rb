class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :project_id, :user_id
      t.string :title, :provider, :provider_document_ref, :provider_owner_names, :mime_type
      t.text :view_link, :icon_link
      t.datetime :file_created_at
      t.timestamps
    end
    
    add_index :documents, [:project_id]
    add_index :documents, [:user_id]
  end
end
