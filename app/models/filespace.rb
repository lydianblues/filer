class Filespace < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :name
  has_many :folders
  belongs_to :root_folder, foreign_key: :folder_id, class_name: Folder
end
