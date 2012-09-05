class Folder < ActiveRecord::Base
  
  class FolderError < StandardError; end
  
  attr_accessible :name
  has_many :links
  has_many :documents, through: :links
  belongs_to :filespace
  
  belongs_to :parent, class_name: Folder, foreign_key: :parent_id,
    inverse_of: :children
  has_many :children, class_name: Folder, foreign_key: :parent_id,
    dependent: :destroy, inverse_of: :parent
  
  def descendent_count
    descendent_count_helper(self)
  end
  
  # Duplicate the file tree rooted at (self, self.filespace) to
  # (target, target.filespace). 'target' must already exist and
  # the copied file tree is attached as a child of the target.
  # Returns the node created as the child of the target.
  def copy!(target, opts = {})
    ActiveRecord::Base.transaction do
      target.leaf = false
      target.save!
      copy_helper(self, target, opts)
    end
  rescue Exception => e
    trace = e.backtrace.join("\n")
    raise FolderError, "Folder#duplicate!: #{e.message}\n#{trace}"
  end
  
  def move!(target)
    ActiveRecord::Base.transaction do
      target.leaf = false
      if self.parent.children.size == 1
        self.parent.leaf = true
      end
      self.parent = target
      self.filespace = target.filespace
      save!
      target.save!
    end
  rescue Exception => e
      trace = e.backtrace.join("\n")
      raise FolderError, "Folder#duplicate!: #{e.message}\n#{trace}"
  end

  private
  
  # Create a new folder with a logical copy of all the
  # files in the folder.  If the recursive flag is set
  # duplicate the subfolders and all their files, etc.
  def copy_helper(folder, target, opts)
    recursive = opts[:recursive]
      
    # 'name', 'leaf', and 'ntype' are copied, id is not
    new_folder = folder.dup
    new_folder.filespace = target.filespace
    target.children << new_folder
    target.save
   
    # Create new links for all documents in the original folder.  Don't
    # use ActiveRecord, since it can all be done in a single database
    # query without multiple trips to the database server.
    sql = <<-"EOS" 
      INSERT INTO links (folder_id, document_id)
        SELECT #{new_folder.id}, document_id from links
        WHERE folder_id = #{folder.id}
    EOS
    
    # Will throw exeception if this fails.
    ActiveRecord::Base.connection.execute(sql)
   
    if (recursive)
      folder.children.each do |subfolder|
        copy_helper(subfolder, new_folder, opts)
      end
    end
    new_folder
  end
  
  #  Count all the descendents, not counting the given folder itself.
  def descendent_count_helper(folder)
    folder.children.inject(folder.children.all.size) do |sum, child|
      descendent_count_helper(child) + sum
    end
  end
end
