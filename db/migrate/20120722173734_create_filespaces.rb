class CreateFilespaces < ActiveRecord::Migration
  def change
    create_table :filespaces do |t|
      t.string :name
      t.timestamps
    end
  end
end
