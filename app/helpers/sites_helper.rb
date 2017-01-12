module SitesHelper
  def sites_to_markers(sites)
    sites.reject(&:nil?).map {|site| MapHelper::Marker.new(site.latitude, site.longitude, site.to_s) }
  end

  def sites_map(sites, size, zoom = nil, pos_field_id = nil)
    map(sites_to_markers(sites), size: size, zoom: zoom, pos_field_id: pos_field_id)
  end
  
end
