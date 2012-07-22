class Document < ActiveRecord::Base
  belongs_to :folder
  attr_accessible :document, :folder_id, :name, :remote_document_url
  mount_uploader :document, DocumentUploader
  
  # So document_path will be defined.
  include Rails.application.routes.url_helpers
  
  # 
   # One convenient method to pass jq_upload the necessary information.
   #
   def to_jq_upload
     {
       "name" => read_attribute(:document),
       "size" => document.size,
       "url" => document.url,
       "thumbnail_url" => document.thumb.url,
       "delete_url" => folder_document_path(folder.id, id: self.id),
       "delete_type" => "DELETE" 
     }
   end

  
end
