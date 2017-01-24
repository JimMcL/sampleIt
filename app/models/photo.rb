# == Schema Information
#
# Table name: photos
#
#  id             :integer          not null, primary key
#  rating         :integer
#  imageable_type :string
#  imageable_id   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  exif_json      :text
#  view_phi       :integer
#  view_lambda    :integer
#  description    :text
#  state          :string
#  ptype          :string
#  source         :string
#  camera         :string
#
# Indexes
#
#  index_photos_on_imageable_type_and_imageable_id  (imageable_type,imageable_id)
#

require 'image_utils'
require 'view_angle'
 
class Photo < ApplicationRecord
  include ImageUtils
  
  has_many :photo_files, :dependent => :destroy
  belongs_to :imageable, polymorphic: true, optional: true

  # Known file types, {:type => FileType}
  FILE_TYPES = [PhotoFileType.new(:photo, 'photos'),
                PhotoFileType.new(:thumb, 'thumbs'),
                PhotoFileType.new(:tiff, 'tiffs'),
               ].map { |ft| [ft.type, ft] }.to_h

  NON_USER_DELETABLE = [:photo, :thumb]
  
  # Creates a new photo instance, saving the image file to the assets directory
  # exif_path - optional name of file containing exif data to be applied to this photo
  # add_scalebar - if true, camera model and magnification are extracted from exif data,
  #                and used to create a tiff in imagej with scale info and a scale bar,
  #                then a jpeg is created to replace the original
  # atts - hash of attributes for the photo, eg rating, description. If there is a view_angle value,
  #                it is converted to view_phi and view_lambda
  def self.create_from_io(io, original_name, mime_type, exif_path, add_scalebar, atts = {})
    # Get a rowid
    photo = Photo.create(convert_view_angle(atts))

    begin
      photo.build_from_io(io, original_name, mime_type, exif_path, add_scalebar)
    rescue => err
      photo.destroy
      raise err
    end
    
    photo
  end

  def self.search(q)
    if q.blank?
      all
    else
      begin
        va = ViewAngle.new(q)
        return where("view_phi = ? AND view_lambda = ?", va.phi, va.lambda) if va.valid?
      rescue
      end
      lk = "%#{q}%"
      where(QueryUtils::q_to_where(q, "photos", [:id, :imageable_id, :ptype], [:imageable_type, :description, :state]))
    end
  end

  # Called from create_from_io
  def build_from_io(io, original_name, mime_type, exif_path, add_scalebar)
    # Work out where the file will be
    photo_file = build_photo_file(:photo, File.extname(original_name))
    photo_files << photo_file
    
    # Always use jpg for thumbnails
    thumb_file = build_photo_file(:thumb, '.jpg')
    photo_files << thumb_file

    # Save the photo file
    photo_file.copy_content(io)
    # Extract EXIF data
    self.exif_json = ImageUtils::exif_to_json(exif_path || photo_file.abs_path)
    # Maybe add a scalebar
    scalebar_file = nil
    if add_scalebar
      scalebar_file = add_scalebar(photo_file)
    else
      # Rotate the image if necessary (already handled if scalebar was added)
      ImageUtils::auto_rotate_image(photo_file.abs_path)
    end
    
    # Generate thumbnail
    generate_thumbnail(photo_file, thumb_file)

    # Maybe fill in some column values from the EXIF
    atts_from_exif
    
    save!
    photo_file.update_size!
  end

  def generate_thumbnail(src, thumb)
    ImageUtils::generate_thumbnail(src.abs_path, thumb.abs_path, 300)
    thumb.update_size!
  end

  # Creates a :tiff file with a scalebar, and overwrites the original file with a jpeg with a scalebar
  def add_scalebar(photo_file)
    tiff_file = build_photo_file(:tiff, '.tif')
    magnification = ExifTags::magnification!(self.exif)
    camera = ExifTags::camera_info!(self.exif)
    ImageUtils::add_scalebar(photo_file.abs_path, tiff_file.abs_path, photo_file.abs_path, camera, magnification)
    photo_files << tiff_file
    tiff_file.update_size!
  end

  def file(type)
    photo_files.where(ftype: type).first || PhotoFile.new
  end

  # Adds a new file representation to this photo
  def add_file(ftype, extension, content)
    pf = PhotoFileType.get(ftype).build_photo_file(id, extension)
    pf.copy_content(content)
    pf.update_size!
    photo_files << pf
  end
  
  # Returns parsed exif JSON data
  def exif
    # Always an array of length 1 - value is hash
    exif_json.blank? ? nil : JSON.parse(exif_json)[0]
  end

  # Returns the location as defined in the exif data
  def location
    ExifTags::location(self.exif)
  end

  # Returns time as defined in the exif data
  def time
    ExifTags::time(self.exif)
  end

  # Returns camera model as defined in the exif data
  def camera_model
    ExifTags::camera_model(self.exif)
  end

  # Returns view_phi and view_lambda as a ViewAngle
  def view_angle
    ViewAngle.new(view_phi, view_lambda)
  end
  
  def view_angle=(view_angle_p)
    if !view_angle_p.is_a?(ViewAngle) && (va = ViewAngle.new(view_angle_p)) && va.valid?
      view_angle_p = va
    end
    if view_angle_p.is_a?(ViewAngle) && view_angle_p.valid?
      self.view_phi = view_angle_p.phi
      self.view_lambda = view_angle_p.lambda
    end
  end

  def label
    l = [ptype, description, view_angle.description, state].reject(&:blank?).join(', ')
    if l.blank?
      l = "Photo #{id}"
    else
      l = "#{id}: #{l}"
    end
    l.capitalize
  end

  def to_s
    l = view_angle.description
    l << ", " unless l.blank?
    "Photo #{id}: #{l}#{imageable}"
  end
  
  private

  def self.convert_view_angle(atts)
    va = ViewAngle.new(atts[:view_angle])
    if va && va.valid?
      atts = atts.clone
      atts[:view_phi] = va.phi
      atts[:view_lambda] = va.lambda
    end
    atts
  end
  
  # Given a named type (eg. :photo, :thumb), returns the PhotoFile instance describing the file
  def build_photo_file(type, extension)
    FILE_TYPES[type].build_photo_file(id, extension)
  end

  def atts_from_exif
    self.camera = camera_model if self.camera.blank?
    self.ptype = deduce_ptype if self.ptype.blank?
  end

  def deduce_ptype
    if !self.camera.blank?
      'Photo'
    end
  end
  
end
