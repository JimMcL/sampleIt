# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Clicking on the Choose file button displays the upload photo sub-form
$ ->
  $("#specimen_photo").click (e) ->
    $(".detail").show('fast')

# Application specific functionality.
# If the uploade file looks like <number>.jpg, set the source to be "Photo <number>"
$ ->
  $("#specimen_photo").change (e) ->
    fn = $(e.target).val().split(/[\\/]/).pop()
    src = $('#photo_source')
    if (m = /^(?:.*[\\/])?(\d+)\.[^.]+/.exec(fn)) && src.val() == ''
      src.val("Photo #{m[1]}")

# Autocomplete on taxon name
$ ->
    $('#specimen_taxon_name').autocomplete
        source: '/taxa/autocomplete.json'
        select: (event,ui) -> $("#specimen_taxon_id").val(ui.item.id)

# Autocomplete on 'other'
$ ->
    $('#specimen_other').autocomplete
        source: window.all_others
        select: (event,ui) -> $('#specimen_other').val(ui.item)

# Autocomplete on 'photo_description'
$ ->
    $('#photo_description').autocomplete
        source: window.all_photo_descriptions
        select: (event,ui) -> $('#photo_description').val(ui.item)
