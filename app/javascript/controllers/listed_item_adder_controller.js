import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "button"]

  show(event) {
    event.preventDefault()
    if (this.hasFormTarget) this.formTarget.classList.remove("hidden")
    if (this.hasButtonTarget) this.buttonTarget.classList.add("hidden")
    this.formTarget.querySelector("textarea, input")?.focus()
  }
}
