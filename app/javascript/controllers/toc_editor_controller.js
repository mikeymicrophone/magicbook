import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { opening: Boolean }

  connect() {
    this.focusInput()
  }

  focusInput() {
    this.inputTargets[0]?.focus()
  }

  open(event) {
    if (this.openingValue) {
      event.preventDefault()
      event.stopImmediatePropagation()
      return
    }

    this.openingValue = true
    event.currentTarget.setAttribute("aria-busy", "true")
  }

  hide(event) {
    event.preventDefault()
    this.element.hidden = true
  }
}
