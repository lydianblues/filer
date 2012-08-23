class DemosController < ApplicationController
   
  def show
   ["User", "Company", "Project", "OutgoingRequest", "IncomingQuote"].each do |name|
      fs = find_or_create_filespace({name: name})
      instance_variable_set("@#{name.downcase}_filespace", fs)
    end
  end

  private

  def find_or_create_filespace(attrs)
    Filespace.find_by_name(attrs[:name]) || Filespace.generate!(attrs)
  end

end
