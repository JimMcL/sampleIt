# -*- coding: utf-8 -*-

# Represents a spatial location, with a latitude, longitude, horizontal error in metres and altitude in metres.
class Location
  attr_accessor :latitude, :longitude, :error, :altitude

  # Creates a location. Position can be specified as numeric values
  # (decimal latitude and longitude, error and altitude) or as a
  # single string or as two strings
  def initialize(lat, lon = nil, err = nil, altitude = nil)
    if lat.is_a? Numeric
      @latitude = lat
      @longitude = lon
      @error = err
      @altitude = altitude
    else
      @latitude, @longitude, @error = parse(lat.to_s + ' ' + lon.to_s + ' ' + err.to_s)
      @altitude = altitude.to_f unless altitude.nil?
    end
  end

  def valid?
    !@latitude.nil? && !@longitude.nil? && @latitude >= -90 && @latitude <= 90 && @longitude >= -180 && @longitude <= 180
  end

  def error_defined?
    !@error.nil? && @error > 0
  end

  # Returns true if the horizontal error in self is less than the horizontal error in other.
  # Assumes that nil or 0 means error is unknown, treated as infinite
  def smaller_error?(other)
    other.nil? || (error_defined? && (!other.error_defined? || @error < other.error))
  end

  # Outputs nicely formated 2D location (no altitude)
  def to_s
    prec = error_defined? ? " +-#{@error.round()} m" : ''
    valid? ? "#{format(@latitude, 'NS')} #{format(@longitude, 'EW')}#{prec}" : ''
  end

  def inspect
    "Location(latitude: #{@latitude}, longitude: #{@longitude}, error: #{error}, altitude: #{altitude})"
  end

  private

  # Attempts to parse lat, lon and error (no altitude)
  def parse(lat_lon_str)
    # Try to guess what sort of format. This is all a bit of a hack

    # First check if there's a horizontal error at the end of the string
    if g = /\+-\s*(?<err>[\.\d]+)/.match(lat_lon_str)
      err = g['err'].to_f
    end

    # Try to parse it strictly first
    result = parse_lat_lon(lat_lon_str)

    # If there's a comma, assume it separates lat and lon
    parts = lat_lon_str.split(',')
    if !result && parts.length == 2
      lat = parts[0].scan(/[+-]?[\d\.]+/)
      lon = parts[1].scan(/[+-]?[\d\.]+/)
      result = [lat[0].to_f, lon[0].to_f] if lat.length >= 1 && lon.length >= 1
    end

    result = result << err if result
    result
  end

  def parse_lat_lon(lat_lon_str)
    regex = %r{
        (?<lat_deg>-?\d{1,2}(\.\d+)?)
        (\D+(?<lat_min>\d{1,2}(\.\d+)?))?
        (\D+(?<lat_sec>\d{1,2}(\.\d+)?))?
        \D*(?<lat_hemi>[NS])
        [\s,]+
        (?<lng_deg>-?\d{1,3}(\.\d+)?)
        (\D+(?<lng_min>\d{1,2}(\.\d+)?))?
        (\D+(?<lng_sec>\d{1,2}(\.\d+)?))?
        \D*(?<lng_hemi>[EW])
    }x

    if g = regex.match(lat_lon_str)
      lat = g['lat_deg'].to_f + g['lat_min'].to_f/60 + g['lat_sec'].to_f/3600
      lat = -lat if g['lat_hemi'] == 'S'
      lng = g['lng_deg'].to_f + g['lng_min'].to_f/60 + g['lng_sec'].to_f/3600
      lng = -lng if g['lng_hemi'] == 'W'
      [lat, lng]
    end
  end

  # secs_precision - 1 arc-second equals roughly 30m, so 2 decimals points gives sub-metre accuracy
  def format(ddeg, hemi, secs_precision = 2)
    h = hemi[ddeg >= 0 ? 0 : 1]
    ddeg = ddeg.abs
    d = ddeg.floor
    m = (ddeg - d) * 60
    mi = m.floor
    s = (m - mi) * 60
    "#{d}° #{mi}′ #{s.round(secs_precision)}″ #{h}"
  end

end

