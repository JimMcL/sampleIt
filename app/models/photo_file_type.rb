require 'fileutils'

# Meta information about a photo file - responsible for the type and directory of PhotoFiles
class PhotoFileType
  # Limit the number of files per directory (http://stackoverflow.com/a/26205776)
  MAX_FILES_PER_DIRECTORY = 250

  attr_accessor :type, :dir

  def self.get(type)
    PhotoFileType.new(type, type.to_s.pluralize)
  end

  # Note: consider calling PhotoFileType::get instead of new
  def initialize(type, dir)
    raise "representation type cannot be left blank" if type.blank?
    @type = type
    @dir = dir
  end

  # Factory method - builds a photo_file
  def build_photo_file(photo_id, extension)
    # Get directory and ensure it exists
    abs = id_to_absolute_dir photo_id
    # Convert to relative path including file name
    rel = abs.relative_path_from(PhotoFile::IMAGES_ROOT).join(id_to_filename(photo_id, extension))

    PhotoFile.new(photo_id: photo_id, ftype: self.type, path: rel)
  end

  private

  # Given a photo id, returns the (absolute) path of the directory where the photo is stored.
  # The directory will be created if it does not exist.
  def id_to_absolute_dir(photo_id)
    env_dir = case Rails.env when 'test'; 'test' when 'development'; 'dev' else ''; end
    abs = PhotoFile::IMAGES_ROOT.join(env_dir, dir, id_to_dirname(photo_id))
    # Ensure directory exists
    FileUtils::mkdir_p(abs)
    abs
  end

  def id_to_filename(photo_id, extension)
    # Maybe should give it an extension based on mime type?
    photo_id.to_s + extension.to_s
  end
  
  def id_to_dirname(photo_id)
    (photo_id.to_i / MAX_FILES_PER_DIRECTORY).to_s
  end
  

end

