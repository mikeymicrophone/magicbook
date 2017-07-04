div_data = []
location_data = {}
$(document).on 'turbolinks:load', ->
  $('.focus_tool').on 'click', 'img', (event) ->
    attachFormTo this

attachFormTo = (table_of_contents) ->
  table = $(table_of_contents).closest('.div_with_data')[0].id
  vertices = table.match /(\w+)_(\d+)/
  div_data = $.map($(table_of_contents).parents('.div_with_data'), (div) ->
    $(div).data()
  )
  $.each(div_data, (i, data) ->
    $.each(Object.keys(data), (j, key) ->
      location_data[key] = data[key]
    )
  )
  debugger
  $.get
    url: '/' + vertices[1] + 's/' + vertices[2] + '/append'
    data: location_data
