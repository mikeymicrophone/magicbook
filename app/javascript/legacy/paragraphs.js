import $ from "jquery"

$(document).on("click", ".focus_tool img", function() {
  const tableOfContents = $(this).closest(".div_with_data")
  const match = tableOfContents.attr("id")?.match(/^([a-z_]+)_([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$/i)
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
