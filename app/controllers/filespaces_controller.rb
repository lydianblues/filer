class FilespacesController < ApplicationController
   
  def index
    @filespaces = Filespace.all
  end

  def show
    @filespace = Filespace.find(params[:id])
    
    # Set the root folder for this filespace.
    @root_folder = @filespace.root_folder
  end

  def new
    @filespace = Filespace.new
  end

  def create
    @filespace = Filespace.generate!(params[:filespace])
  rescue
    render :action => 'new'
  else
    flash[:notice] = "Successfully created filespace."
    redirect_to @filespace
  end

  def edit
    @filespace = Filespace.find(params[:id])
  end
  
  def update
    @filespace = Filespace.find(params[:id])
    if @filespace.update_attributes(params[:filespace])
      flash[:notice] = "Successfully updated filespace."
      redirect_to filespace_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @filespace = Filespace.find(params[:id])
    @filespace.destroy
    flash[:notice] = "Successfully destroyed filespace."
    redirect_to filespaces_url
  end

end
