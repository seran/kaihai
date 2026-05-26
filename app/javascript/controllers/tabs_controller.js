import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values  = { active: String }

  connect() {
    if (!this.activeValue) {
      const first = this.tabTargets[0]
      this.activeValue = first ? first.dataset.tabId : ""
    }
    this.render()
  }

  select(event) {
    this.activeValue = event.currentTarget.dataset.tabId
    this.render()
  }

  render() {
    this.tabTargets.forEach(tab => {
      const active = tab.dataset.tabId === this.activeValue
      tab.setAttribute("aria-selected", active)
      tab.dataset.active = active
    })
    this.panelTargets.forEach(panel => {
      panel.hidden = panel.dataset.tabId !== this.activeValue
    })
  }
}