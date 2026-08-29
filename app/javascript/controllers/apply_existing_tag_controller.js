import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "option", "empty"]

  filter() {
    const query = this.queryTarget.value.trim().toLowerCase()
    let visible = 0

    this.optionTargets.forEach((option) => {
      const match = !query || (option.dataset.label || "").toLowerCase().includes(query)
      option.hidden = !match
      if (match) visible += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible !== 0
  }
}
