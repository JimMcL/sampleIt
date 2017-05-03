module ImageUtils
  # External utilities
  # For now, just assume that ImageMagick is in the path.
  IMAGEMAGICK_CONVERT = "convert"
  IMAGEMAGICK_MOGRIFY = "mogrify"
  IMAGEMAGICK_IDENTIFY = "identify"
  EXIFTOOL = 'C:/Jim/bin/exiftool.exe'
  IMAGEJ = 'C:/Jim/products/Fiji.app/ImageJ-win64.exe'
  

  # Rune the ImageMagick convert process with the specified arguments
  def self.convert(*args)
    system(IMAGEMAGICK_CONVERT, *args)
  end
  
  def self.resize_and_compose(src_path, dest_path, size, overlay_path)
  convert("#{src_path}[0]", "-resize", "#{size}x#{size}", '-auto-orient', overlay_path.to_s, '-gravity', 'center', '-composite', dest_path.to_s)
  end
  
  # Converts source image src_path into a file in dest_path with the specified maximum width/height.
  def self.resize(src_path, dest_path, size)
    # -auto-orient adjusts the image based on exif orientation, then removes exif orientation.
    # Note that if the source is a video, the syntax "file[0]" selects the first frame. This syntax happens to also work on photos
    convert("#{src_path}[0]", "-resize", "#{size}x#{size}", '-auto-orient', dest_path.to_s)
    #system(IMAGEMAGICK_CONVERT, "#{src_path}[0]", "-resize", "#{size}x#{size}", '-auto-orient', dest_path.to_s)
  end


  # Some images have orientation specified in exif data, but browsers don't respect it (except when opened directly as a file!)
  # Adjust the image orientation so it displays correctly
  def self.auto_rotate_image(path)
    system(IMAGEMAGICK_MOGRIFY, '-auto-orient', path.to_s)
  end

  def self.get_dimensions(file)
    # Note: shellwords works for bash, not windows shell
    %x(#{Shellwords::escape(IMAGEMAGICK_IDENTIFY)} -ping -format "%w %h" "#{file}").split(' ')
  end
  
  def self.exif_to_json(file)
    # Exiftool does most of the work. -n means output machine readable values for both tags and tag values
    %x(#{Shellwords::escape(EXIFTOOL)} -n -json #{Shellwords::escape(file)})
  end

  # Adds a scalebar to src, writing the result to dest_tif and/or dest_jpg.
  # camera_info - contains info about camera sensor size and number of pixels (camera_info.rb).
  # magnification - magnification of src photo, may be obtained from exif.
  # sb_width - width of scalebar to create in mm. If nil, an appropriate width is used.
  def self.add_scalebar(src, dest_tif, dest_jpg, camera_info, magnification, sb_width = nil)
    mm_in_pixels = camera_info.dist_in_pixels(1, magnification).round(1)
    pixel_ar = camera_info.pixel_aspect_ratio.round(3)
    sb_width ||= choose_scalebar_width(mm_in_pixels)
    # Build an imagej macro file
    macro_file = build_imagej_macro(src, dest_tif, dest_jpg, mm_in_pixels, pixel_ar, sb_width)
    # Ensure output directories exist
    FileUtils::mkdir_p File.dirname(dest_tif)
    FileUtils::mkdir_p File.dirname(dest_jpg)
    # Run it
    %x(#{IMAGEJ} --headless -macro \"#{macro_file}\")
  end

  ################################################################################
  private

  # Picks an appropriate scalebar width in mm
  def self.choose_scalebar_width(mm_in_pixels)
    max_sb_pixels = 1750
    if mm_in_pixels * 5 > max_sb_pixels
      2
    elsif mm_in_pixels * 2 > max_sb_pixels
      1
    else
      5
    end
  end
  
  def self.build_imagej_macro(image_file, dest_tif, dest_jpg, pixels_in_1mm, aspect_ratio, sb_width)
    # TODO do this properly (i.e. proper temp file name, but careful because ImageJ may not handle paths well)
    file_name = "tmp-scale-bar-macro.ijm"
    # Unfortunately, saving as compressed TIFF loses the scalebar layer
    tc = dest_tif ?
           %Q(run("Save", "save=[#{imagej_file_path(dest_tif)}]");) :
           ''
    jc = dest_jpg ? %Q(saveAs("Jpeg", "#{imagej_file_path(dest_jpg)}");) : ''
    
    File.open(file_name, 'w') do |file|
      file.write(%Q(open("#{imagej_file_path(image_file)}");
run("Set Scale...", "distance=#{pixels_in_1mm} known=1 pixel=#{aspect_ratio} unit=mm");
run("Scale Bar...", "width=#{sb_width} height=16 font=56 color=White background=[Dark Gray] location=[Lower Right] bold overlay");
#{tc}
#{jc}
close();
run("Quit");
))
    end
    file_name
  end

  def self.imagej_file_path(path)
    # There doesn't seem to be a built-in way to handle the drive letter - it is simmply discarded by each_filename!
    drive = /^([a-zA-Z]:)/.match(path.to_s)
    sep = '" + File.separator + "'
    r = Pathname.new(path).each_filename.to_a.join(sep)
    r = drive[0] + sep + r if drive && !r.start_with?(drive[0])
    r
  end

end
