class Folder < ActiveRecord::Base
  attr_accessible :name, :parent_id, :leaf, :filespace_id
  has_many :links
  has_many :documents, through: :links
  belongs_to :filespace
  
  def children
    Folder.where(parent_id: self.id)
  end
  
  def duplicate(filespace_id, parent_id, opts = {})
    duplicate_helper(self, filespace_id, parent_id, opts)
  end 
   
  private
  
  # Create a new folder with a logical copy of all the
  # files in the folder.  If the recursive flag is set
  # duplicate the subfolders and all their files, etc.
  def duplicate_helper(folder, filespace_id, parent_id, opts)
    recursive = opts[:recursive]
    
    # 'name', 'leaf', and 'ntype' are copied, id is not
    new_folder = folder.dup
    
    new_folder.filespace_id = filespace_id
    new_folder.parent_id = parent_id
    new_folder.save!
    
    # Create new links for all documents in the original folder.  Don't
    # use ActiveRecord, since it can all be done in a single database
    # query without multiple trips to the database server.
    sql = "INSERT INTO links (folder_id, document_id) " +
      "SELECT #{new_folder.id}, document_id from links " +
      "where folder_id = #{folder.id}"
      
    # Will throw exeception if this fails.
    ActiveRecord::Base.connection.execute(sql)
    
    if (recursive)
      Folder.where(parent_id: folder.id).each do |subfolder|
        duplicate_helper(subfolder, filespace_id, new_folder.id, opts)
      end
    end
    return new_folder;
  end
end
