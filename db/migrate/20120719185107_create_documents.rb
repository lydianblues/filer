class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :content
      t.string :name
      t.integer :size
      t.string :url
      t.integer :checksum
      t.timestamps
    end
  end
end
