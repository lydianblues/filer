class FilespacesController < ApplicationController
  
  def show
    @filespace = Filespace.find(params[:id])
  end
  
  def index
    @filespaces = Filespace.all
  end

  def show
    @filespace = Filespace.find(params[:id])
  end

  def new
    @filespace = Filespace.new
  end

  def create
    @filespace = Filespace.new(params[:filespace])
    ["Incoming", "Current", "Archived", "Trash"].each do |name|
      @filespace.folders.build(name: name)
    end
    if @filespace.save
      flash[:notice] = "Successfully created filespace."
      redirect_to @filespace
    else
      render :action => 'new'
    end
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
