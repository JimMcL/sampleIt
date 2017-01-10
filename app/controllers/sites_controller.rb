require 'location'

class SitesController < ApplicationController

  include HasPhotos

  def index
    @sites = Site.includes(:project).search(params[:q])

    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"sites.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end
 
  def show
    # Don't want this to exist, but too lazy to scrap it properly
    @site = Site.find(params[:id])
    render 'edit'
  end
 
  def new
    @site = Site.new(project_id: cookies[:project_id])
  end
 
  def edit
    @site = Site.find(params[:id])
    @specimen_count = @site.specimens.count
  end
 
  def create
    s_params = site_params
    @site = Site.new(params_for_new(s_params))
    cookies[:project_id] = @site.project_id
    
    extract_photo(@site, s_params, params)
    maybe_set_location_from_photo(@site, s_params)
    maybe_set_started_at_from_photo(@site, s_params)

    if @site.save
      redirect_to edit_site_path(@site.id)
    else
      render 'new'
    end
  end
 
  def update
    @site = Site.find(params[:id])
    
    s_params = extract_photo(@site, site_params, params)
    s_params = maybe_set_location_from_photo(@site, s_params)
    s_params = maybe_set_started_at_from_photo(@site, s_params)

    @site.update(s_params)
    cookies[:project_id] = @site.project_id
    redirect_to edit_site_path(@site.id), alert: @site.errors.full_messages.join(', ').presence
    
  end
 
  def destroy
    @site = Site.find(params[:id])
    @site.destroy
 
    redirect_to sites_path
  end

  private

  def site_params
    params.require(:site).permit(:notes, :location, :photo, :altitude,
                                 :temperature, :weather, :collector, :sample_type, :transect,
                                 :duration, :started_at, :description, :project_id)
  end

  def maybe_set_started_at_from_photo(site, params = {})
    # NOTE this bit of code is dependent on the representation of started_at on the view.
    # If started_at is represented by a text field, the parameter key is :started_at
    # If it's a datetime_select, it is a multi-parameter attribute, which means there are
    # multiple parameters, "started_at(1)", "started_at(2)", and so on. The number can have a type suffix,
    # so it's actually "started_at(1i)"...
    if params[:started_at].blank? && params['started_at(1i)'].blank?
      site.photos.each do |photo|
        t = photo.time
        if !t.blank?
          site.started_at = t
          # Since we will now created a :started_at key, we have to get rid of the multi-parameter keys,
          # started_at(1i), started_at(2i)...
          params = params.slice(params.keys.reject { |key| /^started_at/.match(key) })
          params[:started_at] = t
          break
        end
      end
    end
    params
  end
  
  # If latitude and longitude aren't set in the parameters, and they are defined in a photo,
  # modifies site to the specified location and returns params with lat, lon added
  def maybe_set_location_from_photo(site, params = {})
    # Don't overwrite explicit value
    if params[:location].blank?
      loc = best_location_from_photos(site)
      if !loc.nil? && loc != site.location
        site.location = loc
        params[:latitude] = loc.latitude
        params[:longitude] = loc.longitude
        params[:horizontal_error] = loc.error
        params[:altitude] = loc.altitude
      end
    end
    params
  end
  
  def best_location_from_photos(site)
    location = nil
    # Is there a photo with a location?
    site.photos.each do |photo|
      l = photo.location
      # If this photo has a location and it's more accurate than previous one
      if !l.nil? && l.valid? && l.smaller_error?(location)
        location = l
      end
    end
    location
  end

end
