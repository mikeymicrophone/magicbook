import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "slug", "style", "picker", "trigger", "menu"]

  connect() {
    this.closeOnOutside = this.closeOnOutside.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    this.slugify()
    this.syncTrigger()
  }

  disconnect() {
    this.teardownMenuListeners()
  }

  slugify() {
    if (!this.hasNameTarget || !this.hasSlugTarget) return
    this.slugTarget.value = this.nameTarget.value
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
  }

  toggleMenu(event) {
    event.preventDefault()
    event.stopPropagation()
    this.setMenuOpen(!this.menuOpen)
  }

  chooseStyle(event) {
    event.preventDefault()
    event.stopPropagation()
    if (!this.hasStyleTarget) return

    const option = event.currentTarget
    this.styleTarget.value = option.dataset.styleId || ""
    this.syncTrigger(option)
    this.setMenuOpen(false)
  }

  submitted(event) {
    if (event.detail.success === false) return
    if (this.hasNameTarget) this.nameTarget.value = ""
    if (this.hasSlugTarget) this.slugTarget.value = ""
    if (this.hasStyleTarget) this.styleTarget.value = ""
    this.syncTrigger()
    this.setMenuOpen(false)
  }

  get menuOpen() {
    return this.hasMenuTarget && !this.menuTarget.hidden
  }

  setMenuOpen(open) {
    if (!this.hasMenuTarget || !this.hasTriggerTarget) return

    this.menuTarget.hidden = !open
    this.triggerTarget.setAttribute("aria-expanded", open ? "true" : "false")
    if (this.hasPickerTarget) this.pickerTarget.classList.toggle("is-open", open)

    this.teardownMenuListeners()
    if (open) {
      document.addEventListener("click", this.closeOnOutside)
      document.addEventListener("keydown", this.closeOnEscape)
    }
  }

  closeOnOutside(event) {
    if (this.hasPickerTarget && this.pickerTarget.contains(event.target)) return
    this.setMenuOpen(false)
  }

  closeOnEscape(event) {
    if (event.key !== "Escape") return
    this.setMenuOpen(false)
    this.triggerTarget?.focus()
  }

  teardownMenuListeners() {
    document.removeEventListener("click", this.closeOnOutside)
    document.removeEventListener("keydown", this.closeOnEscape)
  }

  syncTrigger(selectedOption = this.selectedOption()) {
    if (!this.hasTriggerTarget) return

    const styled = Boolean(this.hasStyleTarget && this.styleTarget.value)
    const label = styled ? this.styleLabel(selectedOption) : ""

    this.triggerTarget.textContent = styled ? label : "#"
    this.triggerTarget.title = styled ? `Style: ${label}` : "Choose a style"
    this.triggerTarget.setAttribute("aria-label", styled ? `Style: ${label}` : "Choose a style")
    if (this.hasPickerTarget) this.pickerTarget.classList.toggle("is-styled", styled)
    this.applyStyleColor(styled ? selectedOption?.dataset.styleColor : "")

    if (!this.hasMenuTarget) return
    this.menuTarget.querySelectorAll("[data-style-id]").forEach((option) => {
      const selected = option === selectedOption
      option.classList.toggle("is-selected", selected)
      option.setAttribute("aria-selected", selected ? "true" : "false")
    })
  }

  selectedOption() {
    if (!this.hasMenuTarget || !this.hasStyleTarget) return null
    const id = this.styleTarget.value
    return this.menuTarget.querySelector(`[data-style-id="${CSS.escape(id)}"]`)
  }

  styleLabel(option) {
    return option?.dataset.styleName || option?.textContent.trim() || ""
  }

  applyStyleColor(color) {
    const value = color || ""
    if (this.hasTriggerTarget) this.setStyleColor(this.triggerTarget, value)
    if (this.hasPickerTarget) this.setStyleColor(this.pickerTarget, value)
  }

  setStyleColor(element, color) {
    if (color) {
      element.style.setProperty("--tag-color", color)
    } else {
      element.style.removeProperty("--tag-color")
    }
  }
}
