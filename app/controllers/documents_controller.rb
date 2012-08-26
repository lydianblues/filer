#
# This file is the Rails interface to the DataTables javascript package.
#
class DocumentsController < ApplicationController
  
  def index
    folder_id = params[:folder_id]
    results = Document.dt_query(params)
    render :json => results.to_json
  end
  
  # We destroy the document if and only if it is linked into the current
  # folder and no other folders.
  def destroy
    folder_id = params[:folder_id]
    document_id = params[:id]
    document = Document.find(document_id)
    url = document.content.url
    
    # Destroy by hand so we can maintain the link count via
    # transaction.  We should change this to an after_destroy
    # callback.
    
    count = Link.where(document_id: document_id).size
    link = Link.where(document_id: document_id, folder_id: folder_id).first
    ActiveRecord::Base.transaction do
      link.destroy if link
      if count == 1
        document = Document.find(document_id)
        document.destroy
      end
    end
    
    logger.info("Deleting file at URL: #{url}")
    # File.delete("#{Rails.root}/public#{url}")
    render :nothing => true, :status => :ok
  end

end
