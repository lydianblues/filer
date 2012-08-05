class Link < ActiveRecord::Base
  belongs_to :documents
  belongs_to :folders
end
