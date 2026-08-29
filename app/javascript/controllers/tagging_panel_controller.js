import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  remember() {
    this.scrollY = window.scrollY
  }

  restore() {
    if (this.scrollY == null) return

    const y = this.scrollY
    requestAnimationFrame(() => {
      window.scrollTo(0, y)
      requestAnimationFrame(() => window.scrollTo(0, y))
    })
  }
}
