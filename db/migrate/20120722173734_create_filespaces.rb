class CreateFilespaces < ActiveRecord::Migration
  def change
    create_table :filespaces do |t|
      t.string :name
      t.references :folder
      t.timestamps
    end
  end
end
