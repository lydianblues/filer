class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :content
      t.string :name
      t.references :folder
      t.timestamps
    end
  end
end
