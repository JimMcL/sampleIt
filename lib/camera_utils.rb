module CameraUtils


  class Camera

    attr_reader :flange_focal_distance
    
    # sensor_width - physical width of sensor in mm
    # sensor_height - physical height of sensor in mm
    # width_in_pixels - no. of pixels across sensor
    # height_in_pixels - no. of pixels from top to bottom of sensor
    # flange_focal_distance - distance from lens mounting flage to film plane (https://en.wikipedia.org/wiki/Flange_focal_distance)
    def initialize(sensor_width, sensor_height, width_in_pixels, height_in_pixels, flange_focal_distance)
      @sensor_width = sensor_width
      @sensor_height = sensor_height
      @width_in_pixels = width_in_pixels
      @height_in_pixels = height_in_pixels
      @flange_focal_distance = flange_focal_distance
    end

    # Returns pixel width in mm
    def pixel_width
      @sensor_width / @width_in_pixels
    end
    
    # Returns pixel height in mm
    def pixel_height
      @sensor_height / @height_in_pixels
    end
    
    # Returns the number of pixels for a distance in mm and magnification
    def dist_in_pixels(mm, magnification)
      mm / pixel_width * magnification
    end

    # Returns the aspect ratio of a single pixel
    def pixel_aspect_ratio
      pixel_width / pixel_height
    end

    def inspect
      "Camera{sensor=#{@sensor_width}x#{@sensor_height}, resolution=#{@width_in_pixels}x#{@height_in_pixels}}"
    end
  end

  class Lens
    attr_reader :length
    
    # length - physical length of the lens, see e.g. https://en.wikipedia.org/wiki/Canon_EF_100mm_lensa
    def initialize(length)
      @length = length.to_f
    end

    def to_s
      "Lens{length=#{@length}=#{self.length}}"
    end
    
    def inspect
      "Lens{length=#{@length}=#{self.length}}"
    end
  end

  def self.camera_info_from_model(model)
    # Can't seem to get physical sensor size from exif, obtained from Canon camera specs, configured in config/cameras.yml
    defn = Rails.configuration.x.camera_definitions['camera'][model]
    Camera.new(defn['sensor width'],
               defn['sensor height'],
               defn['width in pixels'],
               defn['height in pixels'],
               defn['flange focal distance'])
    
    #{'Canon EOS 7D' => Camera.new(22.3, 14.9, 5184, 3456, 44)}[model]
  end

  def self.lens_info_from_model(model)
    # Configured in config/cameras.yml
    defn = Rails.configuration.x.camera_definitions['lens'][model]
    Lens.new(defn['length'])
    
    # {'EF100mm f/2.8 Macro USM' => Lens.new(119),
    #  'MP-E65mm f/2.8 1-5x Macro Photo' => Lens.new(98)}[model]
  end
  
end
