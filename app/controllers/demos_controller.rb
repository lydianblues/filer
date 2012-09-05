class DemosController < ApplicationController
   
  def show
   ["User", "Company", "Project", "IncomingRequest", 
     "OutgoingQuote"].each do |name|
      fs = find_or_create_filespace({name: name})
      instance_variable_set("@#{name.downcase}_filespace", fs)
    end
  end

  private

  def find_or_create_filespace(attrs)
    Filespace.where(name: attrs[:name], latest: true).first ||
      Filespace.generate!(attrs)
  end

end
