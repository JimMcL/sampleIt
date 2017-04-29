require 'query_utils'

class PhotosController < ApplicationController

  def index
    # Allow either a single q param or specific column values to be specified
    if params.key?(:q) || params.keys.length < 3 # always get controller and action params
      # Single parameter - intended for interactive use
      @photos = Photo.search(params[:q])
    else
      # Each (whitelisted) parameter is treated as a column name and
      # value.  The query requires rows which satisfy all conditions.
      # In csv, a single photo url is returned. By default it is the
      # :photo file url, but the file type can be specified with the
      # parameter :ftype. Only photos which have a file with that
      # ftype will be returned. Special parameter 'sql' just gets
      # embedded into the where clause
      has_ftype = !!params[:ftype]
      qry = QueryUtils::params_to_where(adjust_query_params(ViewAngle.expand_query_params(query_params)))
      @photos = has_ftype ? Photo.joins(:photo_files).where(*qry) : Photo.where(*qry)
    end
    
    @base_url = request.base_url
    respond_to do |format|
      format.html do
        # Paginate
        @photos = @photos.page(params[:page]).per_page(11).order('rating DESC')
      end
      format.csv do
        @ftype = params[:ftype] || :photo
        headers['Content-Disposition'] = "attachment; filename=\"photos.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end
 
  def show
    @photo = Photo.find(params[:id])
  end

  def edit
    @photo = Photo.find(params[:id])
    render 'show'
  end
 
  def update
    @photo = Photo.find(params[:id])

    p_params = photo_params
    extract_photo_file(@photo, params)

    @photo.update(p_params) unless @photo.errors.present?

    respond_to do |format|
      format.html { redirect_to edit_photo_path(@photo.id), alert: @photo.errors.full_messages.join(', ').presence }
      format.json  { render json: @photo }
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    # Redirect back to wherever we came from
    redirect_to URI(request.referer).path
  end

  private

  def photo_params
    params.require(:photo).permit(:rating, :description, :view_angle, :state, :ptype, :source, :camera)
  end

  def query_params
    params.permit(:id, :rating, :imageable_type, :imageable_id, :view_phi, :view_lambda, :description, :view_angle, :state, :ptype, :source, :ftype, :camera, :sql)
  end

  def extract_photo_file(photo, params)
    if !params[:photo_file].blank?
      begin
        upload_io = params[:photo_file]
        ext = File.extname(upload_io.original_filename)
        ftype = params[:ftype]
        photo.add_file(ftype, ext, upload_io)
        # pf = PhotoFileType.get(ftype).build_photo_file(photo.id, ext)
        # pf.copy_content(upload_io)
        # photo.photo_files << pf
        # pf.update_size!

      rescue => err
        puts "### Error extracting uploaded photo file:\n#{err}\n"
        puts err.backtrace
        photo.errors.add(:photo, err.message)
      end
    end
  end

  # Allow query parameters which are not column names but still mean something.
  # Eg. ftype means ftype on an associated photo file 
  def adjust_query_params(params)
    if params[:ftype]
      params = params.merge({'photo_files.ftype' => params[:ftype]})
    end
    params.except(:ftype)
  end

end
