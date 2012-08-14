class Filespace < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name
  has_many :folders
  belongs_to :root_folder, foreign_key: :folder_id, class_name: Folder
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
      end
      filespace.save!
      filespace
    end
  end
end
