$(document).on 'turbolinks:load', ->
  $('.inviting').on 'click', '#facebook_claim_sharer', (event) ->
    event.preventDefault()
    FB.ui {
      method: 'share'
      href: $(this).attr 'href'
    }, (response) ->
      alert 'Thank you. You can still invite muggles via email until your quota is filled.'
      return
    return
