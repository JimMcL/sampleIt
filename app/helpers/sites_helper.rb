module SitesHelper
  def sites_to_markers(sites)
    sites.map {|site| MapHelper::Marker.new(site.latitude, site.longitude) }
  end
  
  def site_map_url(site, size, zoom = 17)
    static_map(sites_to_markers([site]), size: size, zoom: zoom)
  end
  
  def sites_map_url(sites, size, zoom = nil)
    static_map(sites_to_markers(sites), size: size, zoom: zoom)
  end
end
