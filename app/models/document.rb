class Document < ActiveRecord::Base
  belongs_to :folder
  attr_accessible :content, :folder_id, :name, :remote_document_url
  mount_uploader :content, DocumentUploader
  
  # So folder_document_path will be defined.
  include Rails.application.routes.url_helpers
  
   # 
   # One convenient method to pass jq_upload the necessary information.
   #
   def to_jq_upload
     {
       "name" => read_attribute(:content),
       "size" => content.size,
       "url" => content.url,
       # "thumbnail_url" => content.thumb.url,
       "delete_url" => folder_document_path(folder.id, id: self.id),
       "delete_type" => "DELETE" 
     }
   end

  
end
