$(document).on 'list_item_adder_shown', ->
  $('.form_for_listed_item').off().on 'change', '#listed_item_content_id', ->
    if($('#listed_item_content_type').val() == '')
      $('#listed_item_content_type').val 'List'

$(document).on 'turbolinks:load', ->
  $('.listed_items_in_list .designation_of_listed_item a').attr 'target', '_blank'
  $('.listed_items_in_list .expression_of_listed_item a').attr 'target', '_blank'
  $('.listed_item').on 'click', '.name_of_list', ->
    $(this).parent().siblings().slideToggle(888)
  
  $('#lists').on 'click', 'em', ->
    $(this).next().slideToggle(888)
  
  $(document).trigger 'autocard'
