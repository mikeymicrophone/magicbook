import $ from "jquery"

$(document).on("submit", "#homepage #ramp_form", () => {
  $("#ramp_confirm").text("It worked! Check your email in 45 seconds. In the meantime, would you like to tell people about this?")
})
