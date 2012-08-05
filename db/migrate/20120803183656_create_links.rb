class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :document
      t.references :folder
    end
  end
end
