class CreateFilespaces < ActiveRecord::Migration
  def change
    create_table :filespaces do |t|
      t.string :name
      t.references :root_folder
      t.references :current_folder
      t.references :incoming_folder
      t.references :trash_folder
      t.references :archived_folder
      t.timestamps
    end
  end
end
