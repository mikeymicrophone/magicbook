$(document).on 'turbolinks:load', ->
  $('body').on 'click', '.purchase_trigger', (event) ->
    event.preventDefault()
    $('.stripe-button-el').click()
