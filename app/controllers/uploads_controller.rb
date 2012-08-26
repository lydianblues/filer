# 
# This is the Rails interface for the fileuploads javascript package.
#
class UploadsController < ApplicationController
  
  def index
    render :json => []
  end
  
  # Upload a file with JSON format
  def create
    @document = Document.new(params[:document])
    link = @document.links.build
    folder_id = params[:folder_id]
    link.folder_id = folder_id
    
    uploaded_file = params[:document][:content]
    sha1_digest = Digest::SHA1.hexdigest(uploaded_file.read)
    uploaded_file.rewind
  
    @document.checksum = sha1_digest
    @document.name =  uploaded_file.original_filename
    @document.content_type = uploaded_file.content_type
    @document.size = uploaded_file.size
    
    
    if @document.save
      render :json => [@document.to_jq_upload(folder_id)].to_json			
    else
      render :json => [{error: :unprocessable_entity}], :status => 304
    end
  end
        
  # We destroy the document if and only if it is linked into the current
  # folder and no other folders.
  def destroy
    folder_id = params[:folder_id]
    document_id = params[:id]
    count = Link.where(document_id: document_id).size
    link = Link.where(document_id: document_id, folder_id: folder_id).first
    ActiveRecord::Base.transaction do
      link.destroy if link
      if count == 1
        document = Document.find(document_id)
        document.destroy
      end
    end
    render :json => true
  end

end
