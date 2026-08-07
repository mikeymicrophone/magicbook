$(document).on 'change', '.form_for_listed_item #listed_item_content_id', ->
  if($('#listed_item_content_type').val() == '')
    $('#listed_item_content_type').val 'List'

autocardRefreshTimeout = null
$(document).on 'turbo:before-stream-render', (event) ->
  target = event.target.getAttribute('target')
  return unless target?.match(/^(listed_item_|listed_items_in_list_)/)

  clearTimeout(autocardRefreshTimeout) if autocardRefreshTimeout
  autocardRefreshTimeout = setTimeout ->
    $('#hoverpopup').remove()
    $(document).trigger 'autocard'
  , 0

$(document).on 'turbolinks:load', ->
  $('.listed_items_in_list .designation_of_listed_item a').attr 'target', '_blank'
  $('.listed_items_in_list .expression_of_listed_item a').attr 'target', '_blank'
  $('.listed_item').on 'click', '.name_of_list', ->
    $(this).parent().siblings().slideToggle(888)
  
  $('#lists').on 'click', 'em', ->
    $(this).next().slideToggle(888)
  
  $(document).trigger 'autocard'
