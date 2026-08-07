import $ from "jquery"

$(document).on("click", ".focus_tool img", function() {
  const tableOfContents = $(this).closest(".div_with_data")
  const match = tableOfContents.attr("id")?.match(/(\w+)_(\d+)/)
  if (!match) return

  const locationData = {}
  tableOfContents.parents(".div_with_data").each((_index, element) => {
    Object.assign(locationData, $(element).data())
  })

  $.get({
    url: `/${match[1]}s/${match[2]}/append`,
    data: locationData,
  })
})
