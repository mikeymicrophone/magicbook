$(document).on 'DOMNodeInserted', ->
  $('#form_for_listed_item').off().on 'change', '#listed_item_content_id', ->
    $('#listed_item_content_type').val 'List'
