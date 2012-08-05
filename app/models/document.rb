class Document < ActiveRecord::Base
  has_many :links
  has_many :folders, through: :links

  attr_accessible :content, :name, :remote_document_url
  mount_uploader :content, DocumentUploader
  
  # So folder_document_path will be defined.
  include Rails.application.routes.url_helpers
  
  def self.entries_for_folder(folder_id)
    joins(:links).where("links.folder_id =  ?", folder_id)
  end

   # 
   # One convenient method to pass jq_upload the necessary information.
   #
   def to_jq_upload(folder_id)
     {
       "name" => read_attribute(:content),
       "size" => content.size,
       "url" => content.url,
       # "thumbnail_url" => content.thumb.url,
       "delete_url" => folder_document_path(folder_id, id: self.id),
       "delete_type" => "DELETE" 
     }
   end

  
end
