$(document).on 'DOMNodeInserted', ->
  $('#form_for_listed_item').off().on 'change', '#listed_item_content_id', ->
    if($('#listed_item_content_type').val() == '')
      $('#listed_item_content_type').val 'List'

$(document).on 'turbolinks:load', ->
  $('.listed_items_in_list .designation_of_listed_item a').attr 'target', '_blank'
  $('.listed_items_in_list .expression_of_listed_item a').attr 'target', '_blank'
