module MapHelper
  GOOGLE_MAPS_API_KEY = "AIzaSyDp8ncL4nFw6U1f_5z_65O3XQSBOimFCJU"
  GOOGLE_STATIC_URL = "https://maps.googleapis.com/maps/api/staticmap"

  class Marker
    attr_accessor :colour, :latitude, :longitude

    def initialize(latitude, longitude, colour = '0xff483f')
      self.latitude = latitude
      self.longitude = longitude
      self.colour = colour
    end

    # Invidual marker params don't include style
    def to_param
      if latitude && longitude
          "#{latitude.round(6)},#{longitude.round(6)}"
      end
    end
  end
  
  def static_map(markers, zoom: nil, size: [300, 300], marker_colour: '0xff483f')
    params = {
      size: "#{size[0]}x#{size[1]}",
      key: GOOGLE_MAPS_API_KEY
    }
    params[:zoom] = zoom if zoom
    # TODO Markers must be grouped based on style
    if !markers.empty?
      params[:markers] = "size:mid|color:#{markers[0].colour}|" + markers.map(&:to_param).reject(&:nil?).join('|')
    end
    "#{GOOGLE_STATIC_URL}?#{params.to_query}"
  end
end
