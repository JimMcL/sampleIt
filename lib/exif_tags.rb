require 'date'
require 'camera_utils'

module ExifTags
  # A list of Exif tags
  MACRO_MAG = 'MacroMagnification'
  ORIGINAL_WIDTH = "OriginalImageWidth"
  ORIGINAL_HEIGHT = "OriginalImageHeight"
  CAMERA_MODEL = 'Model'
  LENS_MODEL = 'LensModel'      #Perhaps Lens or LensID would be better?
  LATITUDE = 'GPSLatitude'
  LONGITUDE = 'GPSLongitude'
  ALTITUDE = 'GPSAltitude'
  GPS_HORIZONTAL_ERROR = 'GPSHPositioningError'  # metres
  GPS_IMAGE_DIRECTION = 'GPSImgDirection'
  DATETIME = 'DateTimeOriginal'
  DOF = "DepthOfField"                           # "metres metres"
  FOCUS_DIST_UPPER = "FocusDistanceUpper"        # metres
  FOCUS_DIST_LOWER = "FocusDistanceLower"        # metres
  MIN_FOCAL_LEN = "MinFocalLength"               # mm
  MAX_FOCAL_LEN = "MaxFocalLength"               # mm


  def self.parse_gps_datetime(datetime)
    datetime ? DateTime.strptime(datetime, '%Y:%m:%d %H:%M:%S') : nil
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

  def self.lens_model(exif_hash)
    exif_hash[ExifTags::LENS_MODEL]
  end
  
  def self.lens_info!(exif_hash)
    lens = exif_hash.blank? ? nil : CameraUtils::lens_info_from_model(lens_model(exif_hash))
    # Hacky message to make sense when displayed as a model error
    raise 'does not contain lens model EXIF data' unless lens
    lens
  end

  def self.focus_distance(exif_hash)
    if exif_hash.key?(ExifTags::DOF)
      # Take the mean of the 2 extents of the depth of field as the distance
      exif_hash[ExifTags::DOF].split.inject(0.0){|sum, el| sum + el.to_f} / 2
    elsif exif_hash.key?(ExifTags::FOCUS_DIST_UPPER) && exif_hash.key?(ExifTags::FOCUS_DIST_LOWER)
      # Take the mean of the 2 extents of the focus distance
      (exif_hash[ExifTags::FOCUS_DIST_UPPER] + exif_hash[ExifTags::FOCUS_DIST_LOWER]) / 2
    else
      nil
    end
  end

  def self.focal_length(exif_hash)
    if exif_hash.key?(ExifTags::MIN_FOCAL_LEN) && exif_hash.key?(ExifTags::MAX_FOCAL_LEN)
      (exif_hash[ExifTags::MIN_FOCAL_LEN] + exif_hash[ExifTags::MAX_FOCAL_LEN]) / 2
    else
      nil
    end
  end

  def self.calc_magnification(f, d_o)
    #(1 / (1/f - 1/d_o)) / d_o
    f / (d_o - f)
  end

  # THIS DOESN'T WORK!
  # Reported focus distance does not seem related to the theoretical object distance in a simple way
  def self.derive_magnification(exif_hash)
    f = focal_length(exif_hash)
    #d_o = focus_distance(exif_hash)
    d_o = exif_hash[ExifTags::FOCUS_DIST_LOWER]
    # See https://en.wikipedia.org/wiki/Magnification
    # From http://www.physicsclassroom.com/class/refrn/Lesson-5/The-Mathematics-of-Lenses
    # Magnification equation:
    # magnification = -di / do
    # where do is object distance (i.e. focus distance) and di is image distance.
    # Lens equation:
    # 1/f = 1/do + 1/di
    # where f is focal length
    # so
    # di = 1 / (1/f - 1/do)
    # M = -di / do
    #   = f / (f - do)
    # 
    if f && d_o
      # Convert focal length from mm to metres
      f /= 1000.0

      l = lens_info!(exif_hash)
      c = camera_info!(exif_hash)
      
      # Subtract lens length (converted to metres) from focus distance.
      # I think this is required because focus distance is measured from camera body or sensor, but optics formula measures from the lens
      #d_o -= (lens_info!(exif_hash).length - c.flange_focal_distance) / 1000.0

      puts "Focal length #{f}, lens length #{lens_info!(exif_hash).length / 1000}, adjusted focus dist #{d_o} -> mag #{(f / (f - d_o)).abs} or #{f / (d_o - 2 * f)}"
      # From experimentation, this seems to be the correct formula, but the result is too inaccurate/imprecise to be useful
      f / (d_o - 2 * f)
    end
  end
  
  def self.magnification!(exif_hash)
    # Magnification might be stored directly in exif, or might need to be derived
    unless exif_hash.blank?
      #mag = exif_hash[ExifTags::MACRO_MAG] || derive_magnification(exif_hash)
      mag = exif_hash[ExifTags::MACRO_MAG]
      return mag if mag
    end
    Rails.logger.debug "EXIF data: #{exif_hash}\n"
    raise 'does not contain macro magnification EXIF data'
  end
end
