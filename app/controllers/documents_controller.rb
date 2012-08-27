
#
# This file is the Rails interface to the DataTables javascript package.
#
class DocumentsController < ApplicationController
  
  respond_to :json
  
  def index
    folder_id = params[:folder_id]
    results = Document.dt_query(params)
    respond_with results
  end
  
  # We destroy the document if and only if it is linked into the current
  # folder and no other folders.
  def destroy
    
    # Add logic:  if the folder is not the Trash folder, move the files 
    # to the Trash folder.  Otherwise, really do the delete as implemented
    # below.  Complication: prevent Carrierwave from deleting the files
    # from the upload directory if we're just moving them to the trash.
    # Actually, if you don't call document.destroy, then the callback in
    # Carrierwave won't be triggered.
    
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
    # Carrierwave does the actual delete.
    
    respond_with(nil)
  end

end
