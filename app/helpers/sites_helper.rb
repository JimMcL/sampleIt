module SitesHelper
  def sites_to_markers(sites)
    sites.reject(&:nil?).map {|site| MapHelper::Marker.new(site.latitude, site.longitude) }
  end

  def sites_map(sites, size, zoom = nil)
    map(sites_to_markers(sites), size: size, zoom: zoom)
  end
  
  def site_map(site, size, zoom = 17)
    map(sites_to_markers([site]), size: size, zoom: zoom)
  end
  
end
