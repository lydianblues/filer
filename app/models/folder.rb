class Folder < ActiveRecord::Base
  attr_accessible :name, :parent_id, :leaf, :filespace_id
  has_many :documents
  belongs_to :filespace
end
