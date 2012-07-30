class FoldersController < ApplicationController
  
  respond_to :json
    
  #
  # This is the URL used by jstree to get the children of a node.
  # 
  # /folders.js?id=:id&opr=get_children
  #
  # It really should be "/folder/:id.js?opr=get_children", so that it is
  # handled by the show action instead of the index action.
  # 
  # for creating a node: operation=create_node&id=357&position=1&
  # title=New+node&type=default
  #
  # {
  #   li_attr:
  #   a_attr:
  #   a_attr.href
  #   title:
  #   data: {
  #     jstree: {}
  #   }
  #   children: []
  # }
  #
  # FilespacesController:
  #   show: renders the filespace panel
  #
  # FoldersController
  #    receives XHR for tree node operations:
  #      get_children, create_node, delete_node, rename_node, move_node,
  #      copy_node
  #
  # DocumentsController
  # 
  def index
    
    # Sample params:
    # opr: get_children
    # id: '1'
    # fs: '2'
    # action: index
    # controller: folders
    # format: json
    
    @filespace = Filespace.find(params[:fs])
    
    if params[:opr] == 'get_children'
      if params[:id] == "1"
        # This means use the root folder of the filespace, which may not
        # actually have the 'id' of 1.
        @folder = @filespace.root_folder
      else
        @folder = Folder.find_by_id(params[:id])
      end
      
      if @folder
        @children = Folder.where(parent_id: @folder.id)
        response = @children.map do |f|
          attrs = {id: "node-#{f.id}"}
          attrs[:class] = if f.leaf
            "jstree-leaf"
          else
            "jstree-closed"
          end
          {title: f.name, data: {foo: "bar"}, li_attr: attrs}
        end
        render json: response, status: :ok
      else
        render json: params.to_json, status: :unprocessable_entity
      end
      logger.info "FoldersController#index: #{response.to_yaml}"
    end
  end

  def show
    @folder = Folder.find(params[:id])
  end

  def new
    @folder = Folder.new
  end

  # Invoked only through Javascript
  def create
    parent_id = params[:parent_id]
    parent = Folder.find(parent_id)
    filespace = Filespace.find(parent.filespace_id)
    folder = Folder.new(name: "New Node", parent_id: parent_id)
    filespace.folders << folder
    begin
      ActiveRecord::Base.transaction do
        filespace.save! # also saves the new folder
        parent.leaf = false
        parent.save!
      end
    rescue Exception => e
      render json: nil, status: :unprocessable_entity
    else
      render json: folder.to_json
    end
  end

  def edit
    @folder = Folder.find(params[:id])
  end

  def update
    @folder = Folder.find(params[:id])
    if @folder.update_attributes(params[:folder])
      flash[:notice] = "Successfully updated folder."
      redirect_to folder_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
     @folder = Folder.find(params[:id])
     @folder.destroy
     flash[:notice] = "Successfully destroyed folder."
     redirect_to folders_url
   end
end
