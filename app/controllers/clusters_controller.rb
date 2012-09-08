class ClustersController < ApplicationController
  
  def index
    @clusters = Cluster.all
    bill = Cluster.create!(name: "Bill")
    frank = Cluster.create!(name: "Frank")
    
    
    f = Filespace.generate!(name: "Filespace for Bill")
    g = Filespace.generate!(name: "Another Filespace for Bill")
    bill.filespaces << [f, g]
    f.save!
    g.save!
    @clusters = [bill, frank]
  end
  
  def show
      # A sort of default cluster...
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
