class CreateClusters < ActiveRecord::Migration
  def change
    create_table :clusters do |t|
      t.string :name
      t.references :user
      t.timestamps
    end
    
    create_table :clusterings do |t|
      t.references :cluster
      t.references :filespace
    end
  end
end
