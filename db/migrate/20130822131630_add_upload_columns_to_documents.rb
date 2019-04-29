class AddUploadColumnsToDocuments < ActiveRecord::Migration
  def up
    change_table :documents do |t|
      t.attachment :attachment
    end
  end
  
  def down
    drop_attached_file :documents, :attachment
  end
end
