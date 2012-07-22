class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name
      t.references :filespace
      t.integer :parent_id
      t.timestamps
    end
  end
end
