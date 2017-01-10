require 'date'
require 'camera_utils'

module ExifTags
  # A list of Exif tags
  MACRO_MAG = 'MacroMagnification'
  ORIGINAL_WIDTH = "OriginalImageWidth"
  ORIGINAL_HEIGHT = "OriginalImageHeight"
  CAMERA_MODEL = 'Model'
  LATITUDE = 'GPSLatitude'
  LONGITUDE = 'GPSLongitude'
  ALTITUDE = 'GPSAltitude'
  GPS_HORIZONTAL_ERROR = 'GPSHPositioningError'  # metres
  GPS_IMAGE_DIRECTION = 'GPSImgDirection'
  DATETIME = 'DateTimeOriginal'


  def self.parse_gps_datetime(datetime)
    DateTime.strptime(datetime, '%Y:%m:%d %H:%M:%S')
  end

  def self.location(exif_hash)
    exif_hash.blank? ? nil : 
      Location.new(exif_hash[ExifTags::LATITUDE], exif_hash[ExifTags::LONGITUDE],
                   exif_hash[ExifTags::GPS_HORIZONTAL_ERROR], exif_hash[ExifTags::ALTITUDE])
  end
  
  def self.time(exif_hash)
    exif_hash.blank? ? nil : parse_gps_datetime(exif_hash[ExifTags::DATETIME])
  end

  def self.camera_model(exif_hash)
    exif_hash[ExifTags::CAMERA_MODEL]
  end
  
  def self.camera_info!(exif_hash)
    cam = exif_hash.blank? ? nil : CameraUtils::camera_info_from_model(camera_model(exif_hash))
    # Hacky message to make sense when displayed as a model error
    raise 'does not contain camera model EXIF data' unless cam
    cam
  end

  def self.magnification!(exif_hash)
    mag = exif_hash.blank? ? nil : exif_hash[ExifTags::MACRO_MAG]
    Rails.logger.debug "EXIF data: #{exif_hash}\n" unless mag
    raise 'does not contain macro magnification EXIF data' unless mag
    mag
  end
end
