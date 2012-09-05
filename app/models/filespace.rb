class Filespace < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name
  has_many :folders
  belongs_to :root_folder, class_name: Folder
  belongs_to :current_folder, class_name: Folder
  belongs_to :incoming_folder, class_name: Folder
  belongs_to :trash_folder, class_name: Folder
  belongs_to :archived_folder, class_name: Folder
   
  validates_presence_of :name
  
  def total_folders
    Filespace.where(filespace_id: self.id).all.size
  end

  # Set up a new filespace.
  def self.generate!(attrs)
    ActiveRecord::Base.transaction do
      filespace = Filespace.create!(attrs)
      root = filespace.folders.build(name: "Root")
      root.leaf = false
      filespace.folders << root
      filespace.root_folder = root
      ["incoming", "current", "archived", "trash"].each do |ntype|
        f = filespace.folders.build(name: ntype.titleize)
        f.ntype = ntype
        root.children << f
        filespace.send("#{ntype}_folder=", f)
      end
      filespace.save!
      filespace
    end
  end
end
