import $ from "jquery"

$(document).on("click", ".purchase_trigger", (event) => {
  event.preventDefault()
  $(".stripe-button-el").click()
})
