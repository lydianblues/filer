class Cluster < ActiveRecord::Base
  attr_accessible :name
  
  belongs_to :user
  has_many :clusterings
  has_many :filespaces, through: :clusterings
end
