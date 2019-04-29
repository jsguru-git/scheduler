class ChangeProviderDocumentRefInDocuments < ActiveRecord::Migration
  def up
    change_column :documents, :provider_document_ref, :text
  end

  def down
    change_column :documents, :provider_document_ref, :string
  end
end
