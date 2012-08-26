class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :content
      t.string :name
      t.integer :size
      t.string :url
      t.string :checksum
      t.string :path
      t.string :content_type
      t.timestamps
    end
  end
end
