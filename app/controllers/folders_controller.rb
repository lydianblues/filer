class FoldersController < ApplicationController
  
  respond_to :json
  #
  # This is the URL used by jstree to get the children of a node.
  # 
  # /folders.js?id=:id&opr=children
  #
  # It really should be "/folder/:id.js?opr=children", so that it is
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
    
  def index
     if params[:opr] == 'children'
       @folder = Folder.find(params[:id])
        
      response = [{
        title: "Incoming",
        data: {},
        li_attr: {id: 80, class: "jstree-leaf"}
      },
      {
        title: "Current",
        data: {},
        li_attr: {id: 81, class: "jstree-leaf"}
      },
      {
        title: "Archived",
        data: {},
        li_attr: {id: 82, class: "jstree-leaf"}
      },
      {
        title: "Deleted",
        data: {},
        li_attr: {id: 83, class: "jstree-leaf jstree-last jstree-no-dots"}
      }
      ] 
      respond_with(response)
    else
      # render :json => @myobject.to_json, :status => :unprocessable_entity
    end
  end

  def show
    @folder = Folder.find(params[:id])
  end

  def new
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(params[:folder])
    if @folder.save
      flash[:notice] = "Successfully created folder."
      redirect_to @folder
    else
      render :action => 'new'
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
