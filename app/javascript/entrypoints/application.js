import Rails from "@rails/ujs"
import "@hotwired/turbo-rails"
import $ from "jquery"
import "../controllers"
import "../legacy/autocard"
import "../legacy/lists"
import "../legacy/muggles"
import "../legacy/paragraphs"
import "../legacy/purchases"

window.$ = window.jQuery = $
window.Rails = Rails

Rails.start()

// Keep Turbo Frames and Streams available while full-page navigation remains
// disabled during the progressive migration away from Turbolinks.
window.Turbo.session.drive = false
