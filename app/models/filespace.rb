class Filespace < ActiveRecord::Base
  attr_accessible :name
  has_many :folders
  belongs_to :root_folder, class_name: Folder
  belongs_to :current_folder, class_name: Folder
  belongs_to :incoming_folder, class_name: Folder
  belongs_to :trash_folder, class_name: Folder
  belongs_to :archived_folder, class_name: Folder
  
  has_many :clusterings
  has_many :clusters, through: :clusterings
   
  validates_presence_of :name
  
  class Error < StandardError; end
  
  #
  # Create a snapshot of the current filespace.  The current version
  # number is copied into the snapshot filespace, and the version
  # number of the current filespace is then incremented.
  #
  def snapshot!
    opts = {
      uuid: uuid,
      version: version,
      name: name,
      snapshot: true,
      latest: false
    }
    raise Error, "Can only snapshot latest version" unless latest
    fs = nil
    ActiveRecord::Base.transaction do
      fs = self.class.generate!(opts)
      fs.current_folder = 
        self.current_folder.copy!(fs.root_folder, recursive: true)
      fs.archived_folder = 
        self.archived_folder.copy!(fs.root_folder, recursive: true)
      fs.save!
      self.version += 1
      save!
    end
    fs
  end
  
  def total_folders
    Filespace.where(filespace_id: self.id).all.size
  end

  # Set up a new filespace.
  def self.generate!(opts = {})
    ActiveRecord::Base.transaction do
      filespace = Filespace.create!(name: opts[:name])
      filespace.uuid = opts[:uuid] || `uuidgen`.strip
      filespace.version = opts[:version] || 1
      filespace.latest = opts.has_key?(:latest) ? opts[:latest] : true
      root = filespace.folders.build(name: "Root")
      root.leaf = false
      filespace.folders << root
      filespace.root_folder = root
      folders_to_create = ["incoming", "trash"]
      folders_to_create |= ["current", "archived"] unless opts[:snapshot]
      folders_to_create.each do |ntype|
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
