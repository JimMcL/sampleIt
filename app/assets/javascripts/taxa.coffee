# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
    $('#taxon_parent_taxon_name').autocomplete
      source: '/taxa/autocomplete.json'
      select: (event,ui) -> $("#taxon_parent_taxon_id").val(ui.item.id)

