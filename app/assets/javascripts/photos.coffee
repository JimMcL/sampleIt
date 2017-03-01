# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Sets up click even handlers on anything with a data-rating attribute
# to set the rating of the containing photo
$ ->
  $("img[data-rating]").click (e) ->
    e.preventDefault()
    rating = $(this).data("rating")
    photo_id = $(this).data("photo-id")
    # Update stars
    $(this).removeClass('off').addClass('on')
    $(this).prevAll().removeClass('off').addClass('on')
    $(this).nextAll().removeClass('on').addClass('off')
    # Update database
    $.ajax
            url: "/photos/#{photo_id}"
            type: 'PATCH',
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json'}
            data: JSON.stringify({rating: rating}),
            error: (jqXHR, textStatus, errorThrown) ->
                alert("Ratings change failed: #{textStatus}:\n#{errorThrown}")

  # Autocomplete on photo state
  $('#photo_state').autocomplete
        source: window.all_photo_states
        select: (event,ui) -> $("#photo_state").val(ui.item)

  # Autocomplete on photo ptype
  $('#photo_ptype').autocomplete
        source: window.all_photo_ptypes
        select: (event,ui) -> $("#photo_ptype").val(ui.item)

  # Setup lazy image loading
  $("img").lazyload({
    threshold : 500
 });
