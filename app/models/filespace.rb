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

  # Set up a new filespace.
  def self.generate!(attrs)
    ActiveRecord::Base.transaction do
      filespace = Filespace.create!(attrs)
      root = filespace.folders.create(name: "Root")
      filespace.root_folder = root
      parent_id = root.id
      ["incoming", "current", "archived", "trash"].each do |ntype|
        f = filespace.folders.build(name: ntype.titleize, parent_id: parent_id)
        f.ntype = ntype
        filespace.send("#{ntype}_folder=", f)
      end
      filespace.save!
      filespace
    end
  end
end
