import { Controller } from "@hotwired/stimulus"

const ROOT     = document.documentElement
const FAMILIES = [ "font-sans", "font-mono" ]

export default class extends Controller {
  static targets = [ "theme", "accent", "family" ]
  static values  = { endpoint: { type: String, default: "/user" } }

  connect() {
    this.sync()
  }

  setTheme(event) {
    const value = event.currentTarget.value
    ROOT.dataset.theme = value
    this.persist({ theme: value })
  }

  setAccent(event) {
    const value = event.currentTarget.value
    ROOT.dataset.accent = value
    this.persist({ accent: value })
  }

  setFamily(event) {
    const value = event.currentTarget.value
    this.element.classList.remove(...FAMILIES)
    this.element.classList.add(`font-${value}`)
    this.familyTargets.forEach(t => t.checked = (t.value === value))
  }

  sync() {
    this.themeTargets.forEach(t  => t.checked = (t.value === ROOT.dataset.theme))
    this.accentTargets.forEach(a => a.checked = (a.value === ROOT.dataset.accent))
  }

  async persist(payload) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      await fetch(this.endpointValue, {
        method: "PATCH",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token,
          "Accept":       "application/json"
        },
        body: JSON.stringify({ user: payload })
      })
    } catch (_e) {
      // Anonymous user or transient error — UI already updated for this session.
    }
  }
}