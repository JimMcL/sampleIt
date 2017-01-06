module CameraUtils

  class Camera
    # sensor_width - physical width of sensor in mm
    # sensor_height - physical height of sensor in mm
    # width_in_pixels - no. of pixels across sensor
    # height_in_pixels - no. of pixels from top to bottom of sensor
    def initialize(sensor_width, sensor_height, width_in_pixels, height_in_pixels)
      @sensor_width = sensor_width
      @sensor_height = sensor_height
      @width_in_pixels = width_in_pixels
      @height_in_pixels = height_in_pixels
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
      "Camera{sensor=#{@sensor_width}x#{@sensor_height}, resolution=#{@width_in_pixels}x#{@height_in_pixels}"
    end
  end

  def self.camera_info_from_model(model)
    # Can't seem to get physical sensor size from exif, obtained from Canon camera specs
    {'Canon EOS 7D' => Camera.new(22.3, 14.9, 5184, 3456)}[model]
  end
  
end
