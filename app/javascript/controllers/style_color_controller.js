import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "swatch", "hex"]

  connect() {
    this.preview()
  }

  preview() {
    if (!this.hasInputTarget) return

    const color = this.inputTarget.value
    if (this.hasSwatchTarget) this.swatchTarget.style.setProperty("--tag-color", color)
    if (this.hasHexTarget) this.hexTarget.textContent = color
  }

  reset(event) {
    if (!this.hasInputTarget) return

    this.inputTarget.value = event.currentTarget.dataset.defaultColor
    this.preview()
  }
}
