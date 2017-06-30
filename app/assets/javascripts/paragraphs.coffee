$(document).on 'turbolinks:load', ->
  $('.focus_tool').on 'click', 'img', (event) ->
    attachFormTo this

attachFormTo = (table_of_contents) ->
  table = $(table_of_contents).closest('.div_with_data')[0].id
  vertices = table.match /(\w+)_(\d+)/
  $.get
    url: '/' + vertices[1] + 's/' + vertices[2] + '/append'
