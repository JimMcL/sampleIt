module HasPhotos
  extend ActiveSupport::Concern

  # Returns a list of parameters which can be used to create a new instance, i.e. excluding photo parameters
  def params_for_new(obj_params)
    obj_params.except(:photo)
  end

  # Extracts an uploaded photo from the posted parameters, and adds it to the photos collection on container.
  # If :exif parameter is set, the exif for the photo is taken from it rather than the :photo parameter.
  # Returns parameters with :photo and :exif removed.
  # Note that container is modified but not saved.
  def extract_photo(container, obj_params, all_params)
    if !obj_params[:photo].blank?
      begin
        upload_io = obj_params[:photo]
        exif_path = obj_params[:exif] ? obj_params[:exif].path : nil
        photo = Photo.create_from_io(upload_io, upload_io.original_filename, upload_io.content_type,
                                     exif_path, is_true?(all_params[:scalebar]),
                                     {description: all_params[:photo_description],
                                      view_angle: all_params[:view_angle],
                                      state: all_params[:photo_state],
                                      ptype: all_params[:photo_ptype],
                                      source: all_params[:photo_source]})
        container.photos << photo
      rescue => err
        container.errors.add(:photo, err.message)
      end
    end
    container.errors.empty? ? obj_params.except(:photo, :exif) : nil
  end

  def is_true?(string)
    ActiveRecord::Type::Boolean.new.cast(string)
  end

end
