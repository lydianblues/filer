class Link < ActiveRecord::Base
  belongs_to :document
  belongs_to :folder
end
