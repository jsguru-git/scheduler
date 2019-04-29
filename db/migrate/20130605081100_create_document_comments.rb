class CreateDocumentComments < ActiveRecord::Migration
  def change
    create_table :document_comments do |t|
      t.integer :user_id, :document_id
      t.text :comment
      t.timestamps
    end
    
    add_index :document_comments, [:user_id]
    add_index :document_comments, [:document_id]
  end
end