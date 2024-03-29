# encoding: utf-8

require 'digest'
require 'carrierwave/processing/mime_types'

module CarrierWave
  module Uploader
    module Store
      def store_path(for_file=filename)
        cs = model.checksum
        @path ||= begin
          File.join([store_dir, cs[0..1], cs[2..3],
            cs[4..5], cs[6..-1], for_file])
        end
        Rails.logger.info("store_path: returning #{@path}")
        @path
      end
    end
  end
end

class DocumentUploader < CarrierWave::Uploader::Base
  
  include CarrierWave::MimeTypes

  process :set_content_type

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "uploads"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #  resize_to_fit(width, height)
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #  process :scale => [75, 75]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
