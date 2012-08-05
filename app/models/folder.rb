class Folder < ActiveRecord::Base
  attr_accessible :name, :parent_id, :leaf, :filespace_id
  has_many :links
  has_many :documents, through: :links
  belongs_to :filespace
end
