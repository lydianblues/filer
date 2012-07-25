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
        
        raise "No root folder" unless @folder
        
        @children = Folder.where(parent_id: @folder.id)
        
        response = @children.map do |f|
          {title: f.name,
            data: {foo: "bar"},
            # a_attr: {href: folder_documents_path(doc)},
            li_attr: {id: "node-#{f.id}", class: "jstree-leaf"}
          }
            
        end
        logger.info "FoldersController#index: #{response.to_yaml}"
        respond_with(response)
      else
        # render :json => @myobject.to_json, :status => :unprocessable_entity
      end
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
    filespace.save!
    respond_with(folder)
  rescue Exception => e
    logger.info "FoldersController#create: exception is #{e.message}"
    respond_with(status: :unprocessable_entity)
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
