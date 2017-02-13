# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

set_geo_location = (position, location_id, altitude_id) ->
  c = position.coords
  $(location_id).val = "#{c.latitude}, #{c.langitude} +-#{c.accuracy}"
  $(altitude_id).val = "#{c.altitude}"

$ ->
  $("button[data-get-location]").click (e) ->
    e.preventDefault()
    if (navigator.geolocation)
      # The value of the data-get-location attribute is a prefix used to construct the ids of the fields which are to be filled in:
      # <pre>_location and <pre>_altitude
      id_prefix = $(this).data("get_location")
      geo_success = (position) -> set_geo_location(position, "#{id_prefix}_location", "#{id_prefix}_altitude")
      geo_error = (err) -> alert("Unable to obtain current location: #{err.message}")
      options =
        enableHighAccuracy: true
        timeout: 5000
        maximumAge: 0
      navigator.geolocation.watchPosition(geo_success, geo_error, options);
    else
      alert("Sorry, current location is not available");

$ ->
  $("#spatial-query").click (e) ->
    e.preventDefault()
    # The "5" passed to toUrlValue is precision of lat/lng values
    uri = UpdateQueryString('bounds', window.SiteMap.getBounds().toUrlValue(5))
    # Include the user's search criterion in the query string 
    uri = UpdateQueryString('q', $("#q").val(), uri)
    window.location.href = uri
