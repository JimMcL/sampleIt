
# Sets up click even handlers on anything with a data-toggle-id attribute
# to toggle display of the element with the specified id
$ ->
  $("button[data-toggle-id]").click (e) ->
    e.preventDefault()
    idToToggle = $(this).data("toggle-id")
    $("#" + idToToggle).toggle()
  $("img[data-toggle-id]").click (e) ->
    e.preventDefault()
    idToToggle = $(this).data("toggle-id")
    $("#" + idToToggle).toggle()
