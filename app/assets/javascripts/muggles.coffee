# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#homepage').on 'submit', '#ramp_form', ->
    $('#ramp_confirm').text "It worked! Check your email in 45 seconds. In the meantime, would you like to tell people about this?"
