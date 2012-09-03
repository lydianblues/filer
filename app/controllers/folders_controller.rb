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
          if f.leaf
            attrs[:class] = "jstree-leaf"
            {title: f.name, li_attr: attrs, data: {ntype: f.ntype}}
          else
            attrs[:class] = "jstree-closed"
            {title: f.name, children: [], li_attr: attrs,
              data: {ntype: f.ntype}}
          end
        end
        logger.info response.to_json
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

  # Invoked only through Javascript: "POST /folders.json"
  def create
    parent_id = params[:folder][:parent_id]
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
      logger.info folder.to_json
      render json: folder.to_json
    end
  end

  def edit
    @folder = Folder.find(params[:id])
  end

  # PUT /folders/:id.json
  def update
    @folder = Folder.find(params[:id])
    case params[:operation]
    when "rename_node"
      if @folder.update_attributes(params[:folder])
        render json: nil,  status: :ok
      else
        render json: nil, status: :unprocessable_entity
      end
      
    when "move_node"
      # Support move between filespaces.  Need to make sure that the
      # user has permissions to do this.
      params[:mover][:old_filespace]
      params[:mover][:old_parent]
      filespace_id =  params[:mover][:new_filespace]
      parent_id = params[:mover][:new_parent]
      parent_folder = Folder.find(parent_id)
      
      # Gaping security hole.  Anyone can move any folder to anywhere.
      # On the client side, the client should save the tree before it
      # changes the tree in memory, then restore the tree if the server
      # returns an error.  This is not fatal, however, since the server
      # has the correct tree structure all the client has to do is refresh
      # the page to see the correct tree.
      
      # XXX BUG TODO also if moving the last child of the old parent,
      # turn off the leaf flag of the old parent.
      begin
        ActiveRecord::Base.transaction do
          parent_folder.update_attributes!(leaf: false)
          @folder.update_attributes!(filespace_id: filespace_id,
            parent_id: parent_id)
        end
      rescue Exception => e
        logger.warn "FoldersController#update: Move node failed: #{e.message}"
        status = :unprocessable_entity
      else
        status = :ok
      end
       render json: nil, status: status
       
    when "copy_node"
      filespace_id =  params[:mover][:new_filespace].to_i
      parent_id = params[:mover][:new_parent].to_i
      begin
         @folder.duplicate(filespace_id, parent_id, recursive: true)
      rescue Exception => e
        logger.warn "FoldersController#update: Copy node failed: #{e.message}"
        status = :unprocessable_entity
      else
        status = :ok
      end
       render json: nil, status: status
    end
  end
  
  def destroy
     @folder = Folder.find(params[:id])
     @folder.destroy
     flash[:notice] = "Successfully destroyed folder."
     redirect_to folders_url
   end
end
