module SitesHelper
  def site_map_url(site, size, zoom = 17)
    static_map(site.latitude, site.longitude, size: size, zoom: zoom)
  end
end
