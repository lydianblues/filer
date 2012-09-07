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
    filespace = parent.filespace
    folder = nil
    begin
      ActiveRecord::Base.transaction do
        folder = Folder.new(name: "New Node")
        logger.info "Filespace id is #{filespace.id}"
        folder.filespace_id = filespace.id
        parent.children << folder
        
        # filespace.save! # also saves the new folder
        parent.leaf = false
        parent.save!
      end
    rescue Exception => e
      logger.info e.message
      logger.info e.backtrace.join("\n")
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
       target_folder_id = params[:mover][:new_parent].to_i
      
      # On the client side, the client should save the tree before it
      # changes the tree in memory, then restore the tree if the server
      # returns an error.  This is not fatal, however, since the server
      # has the correct tree structure all the client has to do is refresh
      # the page to see the correct tree.
      
      begin
        target_folder = Folder.find(target_folder_id)
        @folder.move!(target_folder)
      rescue Exception => e
        logger.warn "FoldersController#update: Move node failed: #{e.message}"
        status = :unprocessable_entity
      else
        status = :ok
      end
       render json: nil, status: status
       
    when "copy_node"
      filespace_id =  params[:mover][:new_filespace].to_i
      target_folder_id = params[:mover][:new_parent].to_i
      begin
         target_folder = Folder.find(target_folder_id)
         @folder.copy!(target_folder, recursive: true)
      rescue Exception => e
        logger.warn "FoldersController#update: Copy node failed: #{e.message}"
        status = :unprocessable_entity
      else
        status = :ok
      end
       render json: nil, status: status
    
    when "paste_files"
      target_fs_id = params[:target_fs]
      target_folder_id = params[:target_folder]
      begin
        target_filespace = Filespace.find(target_fs_id)
        target_folder = Folder.find(target_folder_id)
        if target_folder.filespace != target_filespace
          raise "Invalid filespace or folder"
        end
        doc_ids = params[:documents] || []
        doc_ids.each do |doc_id|
          link = Link.where(folder_id: target_folder_id,
            document_id: doc_id).first
          unless link
            doc = Document.find(doc_id)
            target_folder.documents << doc
          end
        end
      rescue Exception => e
        logger.warn "FoldersController#update: " +
          "Paste files failed: #{e.message}"
        status = :unprocessable_entity
      else
        status = :ok
      end
      results = {filespace: target_fs_id, folder: target_folder_id}.to_json
      render json: results, status: status
    end
  end
  
  def destroy
     @folder = Folder.find(params[:id])
     # Need to destroy links too..
     @folder.destroy
     flash[:notice] = "Successfully destroyed folder."
     redirect_to folders_url
   end
end
