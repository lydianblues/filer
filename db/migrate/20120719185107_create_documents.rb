class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :document
      t.string :name
      t.references :folder
      t.timestamps
    end
  end
end
