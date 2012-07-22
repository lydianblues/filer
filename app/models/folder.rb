class Folder < ActiveRecord::Base
  attr_accessible :name
  has_many :documents
  belongs_to :filespace
end
