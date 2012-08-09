class DocumentsController < ApplicationController
  
  #
  # This is called by the fileuploader to get all the documents in
  # a given folder.  Return JSON format.
  #
  def index
    folder_id = params[:folder_id]
    @documents = Document.entries_for_folder(folder_id).all
    json = @documents.collect {|p| p.to_jq_upload(folder_id)}.to_json
    logger.info(json)
    render :json => json
  end
  
  # Upload a file with JSON format
  def create
    @document = Document.new(params[:document])
    link = @document.links.build
    folder_id = params[:folder_id]
    link.folder_id = folder_id
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
