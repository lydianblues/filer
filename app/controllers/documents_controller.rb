class DocumentsController < ApplicationController
  
   def index
    @documents = Document.where(folder_id: params[:folder_id]).all
    render :json => @documents.collect {|p| p.to_jq_upload }.to_json
  end
  
  def new
    @document = Document.new(:folder_id => params[:folder_id])
  end
  
  def create
    # folder = Folder.find(params[:folder_id])
    params[:document].merge!(folder_id: params[:folder_id])
    @document = Document.new(params[:document])
    if @document.save
      respond_to do |format|
        format.html do 
          render(:json => [@document.to_jq_upload].to_json, 
            :content_type => 'text/html', :layout => false)
        end
        format.json do 
          render :json => [@document.to_jq_upload].to_json			
        end
      end
    else 
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end
    
  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    render :json => true
  end

end
