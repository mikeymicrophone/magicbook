import $ from "jquery"

const CARD_HEIGHT = 310
const CARD_WIDTH = 220
const URL_START_DEFAULT = "http://www.mtg-forum.de/db/magiccard.php"
const URL_START_IMG_DEFAULT = "http://magiccards.info/scans"
const WIZARDS_IMAGE_URL = "http://gatherer.wizards.com/Handlers/Image.ashx?type=card&name="

let popup

function normalizedCardName(cardName) {
  return cardName
    .replace(/&#8217;/g, "")
    .replace(/[\u0092\u2019]/g, "'")
    .replace(/-/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .replace(/ /g, "%20")
}

function imageSource(element, urlStartImage) {
  if (element.href?.includes(urlStartImage)) return element.href
  if (element.href) return `${WIZARDS_IMAGE_URL}${normalizedCardName(element.textContent || "")}`

  return null
}

function hidePopup() {
  if (popup) popup.style.visibility = "hidden"
}

function popupTop(element) {
  let top = element.offsetTop + element.offsetHeight
  let parent = element.offsetParent

  while (parent) {
    top += parent.offsetTop || 0
    parent = parent.offsetParent
  }

  return Math.min(top, document.body.offsetHeight - CARD_HEIGHT)
}

function popupLeft(element) {
  let left = element.offsetLeft + element.offsetWidth
  let parent = element.offsetParent

  while (parent) {
    left += parent.offsetLeft || 0
    parent = parent.offsetParent
  }

  return Math.min(left, document.body.offsetWidth - CARD_WIDTH)
}

function showPopup(element, urlStartImage) {
  const source = imageSource(element, urlStartImage)
  if (!source || !popup) return

  popup.replaceChildren()
  popup.style.top = `${popupTop(element)}px`
  popup.style.left = `${popupLeft(element)}px`

  const image = document.createElement("img")
  image.src = source
  image.width = CARD_WIDTH
  image.height = CARD_HEIGHT
  image.addEventListener("error", hidePopup, { once: true })
  popup.append(image)
  popup.style.visibility = "visible"
}

function initializeAutocard() {
  $("#hoverpopup").remove()
  popup = document.createElement("div")
  popup.id = "hoverpopup"
  popup.className = "card"
  popup.style.cssText = "visibility: hidden; position: absolute; top: 10px; left: 5px;"
  document.body.append(popup)

  const urlStart = window.URL_START || URL_START_DEFAULT
  const urlStartImage = window.URL_START_IMG || URL_START_IMG_DEFAULT

  document.querySelectorAll("a").forEach((link) => {
    if (!link.classList.contains("mtgcard") && !link.href.includes(urlStart) && !link.href.includes(urlStartImage)) return

    link.onmouseover = () => showPopup(link, urlStartImage)
    link.onmouseout = hidePopup
  })
}

window.hideImgPopup = hidePopup
$(document).on("autocard", initializeAutocard)
