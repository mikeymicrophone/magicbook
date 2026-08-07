import $ from "jquery"

let autocardRefreshTimeout

$(document).on("change", ".form_for_listed_item #listed_item_content_id", () => {
  const contentType = $("#listed_item_content_type")

  if (contentType.val() === "") contentType.val("List")
})

$(document).on("turbo:before-stream-render", (event) => {
  const target = event.target.getAttribute("target")
  if (!target?.match(/^(listed_item_|listed_items_in_list_)/)) return

  clearTimeout(autocardRefreshTimeout)
  autocardRefreshTimeout = setTimeout(() => {
    $("#hoverpopup").remove()
    $(document).trigger("autocard")
  }, 0)
})

$(document).on("click", ".listed_item .name_of_list", function() {
  $(this).parent().siblings().slideToggle(888)
})

$(document).on("click", "#lists em", function() {
  $(this).next().slideToggle(888)
})

document.addEventListener("turbo:load", () => {
  $(".listed_items_in_list .designation_of_listed_item a").attr("target", "_blank")
  $(".listed_items_in_list .expression_of_listed_item a").attr("target", "_blank")
  $(document).trigger("autocard")
})
