module MapHelper
  GOOGLE_MAPS_API_KEY = "AIzaSyDp8ncL4nFw6U1f_5z_65O3XQSBOimFCJU"
  GOOGLE_API_URL = "https://maps.googleapis.com/maps/api"
  GOOGLE_STATIC_URL = "#{GOOGLE_API_URL}/staticmap"
  GOOGLE_JS_URL = "#{GOOGLE_API_URL}/js"

  class Marker
    attr_accessor :colour, :latitude, :longitude

    def initialize(latitude, longitude, colour = '0xff483f')
      self.latitude = latitude
      self.longitude = longitude
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
          "{lat: #{latitude.round(5)}, lng: #{longitude.round(5)}}"
      end
    end

    def to_s
      to_LatLng
    end
  end

  class Bounds
    
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

    def to_s
      "new google.maps.LatLngBounds(#{sw}, #{ne})"
    end

    def inspect
      "#{self.class}<#{@north}, #{@south}, #{@east}, #{@west}>"
    end
  end

  # Assume single map per page
  def map(markers, zoom: nil, size: [300, 300])

    # I think it make sense to limit the number of markers
    marker = markers.take(1000)
    
    params = {
      key: GOOGLE_MAPS_API_KEY,
      callback: 'initMap'
    }
    # Calculate bounds of all markers
    bounds = Bounds.new
    markers.each { |m| bounds.extend(m) }
    
    marker_js = markers.select(&:valid?).map {|m| "new google.maps.Marker({position: #{m.to_LatLng}, map: map});" }.join("\n")
      
    content_tag(:div, nil, {class: 'map', id: 'map', style: "width:#{size[0]}px; height:#{size[1]}px"}) +
      javascript_tag("
 function initMap() {
        var bounds = #{bounds};
        var map = new google.maps.Map(document.getElementById('map'), {
          zoom: #{zoom || 8},
          center: bounds.getCenter()
        });
        #{zoom.nil? ? 'map.fitBounds(bounds);' : ''}
        #{marker_js}
      }
") +
      javascript_tag(nil, {src: "#{GOOGLE_JS_URL}?#{params.to_query}".html_safe})
    
  end
  
end
