import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "handle", "hint"]
  static values  = { url: String }

  connect() {
    this.userEdited = this.handleTarget.value.trim().length > 0
  }

  nameInput() {
    if (this.userEdited) return

    const slug = this.slugify(this.nameTarget.value)
    this.handleTarget.value = slug
    this.markAvailable()
    this.schedule(() => this.checkFromName(slug))
  }

  handleEdited() {
    this.userEdited = true
    this.markAvailable()

    const slug = this.handleTarget.value.trim()
    this.schedule(() => this.checkFromHandle(slug))
  }

  async checkFromName(slug) {
    if (this.userEdited) return
    const data = await this.fetchSuggestion(slug)
    if (!data || this.userEdited) return
    if (this.slugify(this.nameTarget.value) !== slug) return // user kept typing

    if (data.handle === slug) {
      this.markFree()
    } else {
      this.handleTarget.value = data.handle
      this.markTaken()
    }
  }

  async checkFromHandle(slug) {
    const data = await this.fetchSuggestion(slug)
    if (!data) return
    if (this.handleTarget.value.trim() !== slug) return // user kept typing

    if (data.handle === slug) {
      this.markFree()
    } else {
      this.markTaken()
    }
  }

  async fetchSuggestion(slug) {
    if (!slug || slug.length < 3) return null
    const url = this.hasUrlValue ? this.urlValue : "/spaces/handle_suggestion"
    const sep = url.includes("?") ? "&" : "?"
    try {
      const response = await fetch(`${url}${sep}handle=${encodeURIComponent(slug)}`, {
        headers: { Accept: "application/json" }
      })
      if (!response.ok) return null
      return await response.json()
    } catch (_e) {
      return null
    }
  }

  schedule(fn) {
    clearTimeout(this.timer)
    this.timer = setTimeout(fn, 350)
  }

  markTaken() {
    this.handleTarget.dataset.suggested = "taken"
    if (this.hasHintTarget) this.hintTarget.hidden = false
  }

  markFree() {
    this.handleTarget.dataset.suggested = "free"
    if (this.hasHintTarget) this.hintTarget.hidden = true
  }

  markAvailable() {
    delete this.handleTarget.dataset.suggested
    if (this.hasHintTarget) this.hintTarget.hidden = true
  }

  slugify(input) {
    return input
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9_]+/g, "_")
      .replace(/_+/g, "_")
      .replace(/^_+|_+$/g, "")
      .slice(0, 20)
  }
}
