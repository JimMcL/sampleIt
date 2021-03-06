require 'fileutils'

# Meta information about a class of photo files - responsible for the type and directory of PhotoFiles
# Root directories are defined by rails conventions, images are under /public/images, videos under /public/videos.
# The root field only stores the last path component.
class AttachmentFileType

  # Known file types, {:type => FileType}
  @@file_types = {}
  @@fallback = nil

  attr_accessor :type, :dir, :asset_type, :root

  # Register a file type
  def self.register(*file_types)
    file_types.each do |ft|
      @@file_types[ft.type] = ft
    end
  end

  def self.register_fallback(file_type)
    raise "Duplicate attachment fallback file type #{file_type}" if @@fallback
    @@fallback = file_type
  end
  
  # Returns a AttachmentFileType given its code 
  def self.get(type)
    @@file_types[type.to_sym]
  end

  # Choose an attachment file type from a content type
  def self.choose(content_type)
    @@file_types.values.select { |ft| ft.can_handle?(content_type) }.first || @@fallback
  end
  
  # To get a predefined type, call #get
  # asset_type is a rails asset type, see ActionView::Helpers::AssetUrlHelper::ASSET_PUBLIC_DIRECTORIES
  def initialize(type, asset_type, root = nil)
    raise "representation type cannot be left blank" if type.blank?
    @type = type
    @dir = type.to_s.pluralize
    @asset_type = asset_type
    # Use ASSET_PUBLIC_DIRECTORIES to get root dir, but remove leading "/"
    @root = root || ActionView::Helpers::AssetUrlHelper::ASSET_PUBLIC_DIRECTORIES[asset_type][1..-1]
  end

  # Factory method - builds a photo_file
  def build_photo_file(photo_id, extension)
    # Get directory and ensure it exists
    abs = id_to_absolute_dir photo_id
    # Convert to relative path including file name
    rel = abs.relative_path_from(root_path).join(id_to_filename(photo_id, extension))

    PhotoFile.new(photo_id: photo_id, ftype: self.type, path: rel)
  end

  def can_handle?(content_type)
    false
  end

  def allow_scalebar?
    false
  end

  def allow_auto_rotate?
    false
  end

  def extract_dimensions(path)
  end

  # Returns the root as an absolute directory
  def root_path
    Rails.root.join('public', root)
  end

  def to_s
    "#{self.class.name} #{type}"
  end

  private


  # Limit the number of files per directory (http://stackoverflow.com/a/26205776)
  MAX_FILES_PER_DIRECTORY = 250
  
  # Given a photo id, returns the (absolute) path of the directory where the photo is stored.
  # The directory will be created if it does not exist.
  def id_to_absolute_dir(photo_id)
    env_dir = case Rails.env when 'test'; 'test' when 'development'; 'dev' else ''; end
    abs = root_path.join(env_dir, dir, id_to_dirname(photo_id))
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

  ################################################################################

  # Specific attachment file types

  # Image attachments
  class ImageFileType < AttachmentFileType

    def initialize(type)
      super(type, :image)
    end

    AttachmentFileType.register(ImageFileType.new(:photo),
                                ImageFileType.new(:thumb),
                                ImageFileType.new(:tiff))
    

    def generate_thumbnail(src_path, thumb_path, thumb_size)
      ImageUtils::resize(src_path, thumb_path, thumb_size)
    end

    def extract_dimensions(path)
      ImageUtils::get_image_dimensions(path)
    end

    def can_handle?(content_type)
      content_type.starts_with?('image')
    end

    def allow_scalebar?
      true
    end

    def allow_auto_rotate?
      true
    end

  end

  ################################################################################

  # Video attachments
  class VideoFileType < AttachmentFileType

    VIDEO_PLAY_STAMP = Rails.root.join('app', 'assets', 'images', 'play.png')

    def initialize(type)
      super(type, :video)
    end

    AttachmentFileType.register(VideoFileType.new(:video))

    def generate_thumbnail(src_path, thumb_path, thumb_size)
      ImageUtils::video_thumbnail(src_path, thumb_path, thumb_size, VIDEO_PLAY_STAMP)
    end

    def extract_dimensions(path)
      ImageUtils::get_video_dimensions(path)
    end

    def can_handle?(content_type)
      content_type.starts_with?('video')
    end
  end

  ################################################################################

  # Audio attachments
  class AudioFileType < AttachmentFileType
    def initialize(type)
      super(type, :audio)
    end

    AttachmentFileType.register(AudioFileType.new(:audio))

    def can_handle?(content_type)
      content_type.starts_with?('audio')
    end
  end

  ################################################################################

  # Arbitrary attachments
  class DataFileType < AttachmentFileType
    def initialize(type)
      super(type, :attachment, 'attachments')
    end

    AttachmentFileType.register_fallback(DataFileType.new(:attachment))
  end

