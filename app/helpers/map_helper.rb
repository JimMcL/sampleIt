# Methods for building and interacting with google maps
module MapHelper
  GOOGLE_MAPS_API_KEY = "AIzaSyDp8ncL4nFw6U1f_5z_65O3XQSBOimFCJU"
  GOOGLE_API_URL = "https://maps.googleapis.com/maps/api"
  GOOGLE_STATIC_URL = "#{GOOGLE_API_URL}/staticmap"
  GOOGLE_JS_URL = "#{GOOGLE_API_URL}/js"

  class Marker
    attr_accessor :colour, :latitude, :longitude, :title

    def initialize(latitude, longitude, title = nil, colour = '0xff483f')
      self.latitude = latitude
      self.longitude = longitude
      self.title = title
      self.colour = colour
    end

    def valid?
      latitude && longitude
    end
    
    # Invidual marker params don't include style
    def to_param
      if latitude && longitude
          "#{latitude.round(6)},#{longitude.round(6)}"
      end
    end

    def to_LatLng
      if latitude && longitude
          {lat: latitude.round(5), lng: longitude.round(5)}
      end
    end

    def to_s
      to_js(to_LatLng)
    end

    def to_javascript(map_name, pos_field_id)

      args = {position: to_LatLng, map: map_name.to_sym}
      args[:title] = title if title
      args[:draggable] = true if pos_field_id
      args_js = to_js(args)
      js = %Q(marker = new google.maps.Marker(#{args_js});)
      if pos_field_id
        js << %Q{
          google.maps.event.addListener(marker, 'dragend', function(event) {
              var pos_field = $('##{pos_field_id}');
              pos_field.val(this.getPosition().toUrlValue());
              pos_field.addClass('modified');
          });}
      end
      js
    end

    private

    def to_js(val)
      if val.is_a? Hash
        '{' + val.map { |k,v| "#{k}: #{to_js(v)}" }.join(', ') + '}'
      elsif val.is_a? Array
        '[' + val.map { |v| to_js(v) }.join(', ') + ']'
      elsif val.is_a? String
        '"' + val + '"'
      else
        val
      end
    end
    
    def maybe_quote(value)
      if value.is_a? String
        '"' + value + '"'
      else
        value
      end
    end

  end

  class Bounds
    attr_accessor :north, :south, :east, :west

    DEGREES_TO_METRES_FACTOR = 111111
    
    # Parse bounds in format "lat_lo,lng_lo,lat_hi,lng_hi"
    def initialize(str = nil)
      if str.is_a? String
        @south, @west, @north, @east = str.split(',')
      end
    end

    def valid?
      sw.valid? && ne.valid?
    end
    
    def extend(marker)
      if marker.valid?
        @north = marker.latitude if @north.nil? || marker.latitude > @north
        @south = marker.latitude if @south.nil? || marker.latitude < @south
        @east = marker.longitude if @east.nil? || marker.longitude > @east
        @west = marker.longitude if @west.nil? || marker.longitude < @west
      end
    end

    def sw
      Marker.new(@south, @west)
    end

    def ne
      Marker.new(@north, @east)
    end

    def centre
      Marker.new((@south + @north) / 2, (@west + @east) / 2)
    end

    # Ensures that self is at least min_metres in width or height.
    # Returns self
    def ensure_at_least(min_metres)
      c = centre
      width = deg2metres(@east - @west, c.latitude)
      height = deg2metres(@north - @south)
      if width < min_metres && height < min_metres
        dx = metres2deg(min_metres.to_f / 2, c.latitude)
        @west = c.longitude - dx
        @east = c.longitude + dx
        dy = metres2deg(min_metres.to_f / 2)
        @south = c.latitude - dy
        @north = c.latitude + dy
      end
      self
    end

    # Simplistic conversion of metres to decimal east/west or north/south degrees.
    # dist_in_metres - distance to be converted
    # at_latitude - latitude of measurement for east/west measurements,
    #               0 (the default) for north/south measurements
    def metres2deg(dist_in_metres, at_latitude = 0)
        dist_in_metres.to_f / DEGREES_TO_METRES_FACTOR / Math::cos(deg2rad(at_latitude))
    end
    
    # Simplistic conversion of north/south or east/west distance in decimal degrees to metres.
    # dist_in_degrees - distance to be converted
    # at_latitude - latitude of measurement for east/west measurements,
    #               0 (the default) for north/south measurements
    def deg2metres(dist_in_degrees, at_latitude = 0)
      dist_in_degrees * DEGREES_TO_METRES_FACTOR * Math::cos(deg2rad(at_latitude))
    end

    def deg2rad(deg)
      deg * Math::PI / 180
    end
  
    def to_s
      if valid?
        "new google.maps.LatLngBounds(#{sw}, #{ne})"
      end
    end

    def inspect
      "#{self.class}<#{@north}, #{@south}, #{@east}, #{@west}>"
    end
  end

  # Constructs HTML and javascript for a google map with markers. Map
  # will be centred on the markers.  Assumes single map per page.
  # 
  # markers - array of Marker objects
  # zoom - google maps zoom level. If zoom is nil and >1 markers, map will be zoomed to cover all markers.
  # size - size in pixels of the map
  # pos_field_id - if not nil, specifies the ID of a field containing
  #     a location. If a marker is dragged, the field will be updated with
  #     the new location of the marker. Intention is that the map
  #     represents a single marker, so moving the marker updates its position
  def map(markers, zoom: nil, size: [300, 300], pos_field_id: nil)

    # I think it make sense to limit the number of markers
    markers = markers.take(1000)
    
    params = {
      key: GOOGLE_MAPS_API_KEY,
      callback: 'initMap'
    }
    # Calculate bounds of all markers
    bounds = Bounds.new
    markers.each { |m| bounds.extend(m) }

    style = "width:#{size[0]}px; height:#{size[1]}px"
    if bounds.valid?
      markers_js = markers.select(&:valid?).map {|m| m.to_javascript('map', pos_field_id)}.join("\n")

      content_tag(:div, nil, {class: 'map', id: 'map', style: style}) +
        javascript_tag(build_map_init_fn(bounds.ensure_at_least(200), 'map', zoom, markers_js)) +
        javascript_tag(nil, {src: "#{GOOGLE_JS_URL}?#{params.to_query}".html_safe})
    else
      content_tag(:div, nil, {class: 'map nowhere', id: 'map', style: style})
    end
    
  end

  ################################################################################
  private

  def build_map_init_fn(bounds, map_ele_id, zoom, markers_js)
    %Q{
 function initMap() {
        var bounds = #{bounds};
        var map = new google.maps.Map(document.getElementById('#{map_ele_id}'), {
          zoom: #{zoom || 8},
          center: bounds.getCenter(),
        });
        window.SiteMap = map;
        #{zoom.nil? ? 'map.fitBounds(bounds);' : ''}
        #{markers_js}
}
}
  end

end
