class DemosController < ApplicationController
   
  def show
    @filespaces = []
    ["User", "Company", "Project", "IncomingRequest", 
      "OutgoingQuote"].each do |name|
      fs = find_or_create_filespace({name: name})
      @filespaces << fs
    end
  end

  private

  def find_or_create_filespace(attrs)
    Filespace.where(name: attrs[:name], latest: true).first ||
      Filespace.generate!(attrs)
  end

end
