import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 5000 } }

  connect() {
    if (this.durationValue > 0) {
      this.timer = setTimeout(() => this.dismiss(), this.durationValue)
    }
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    clearTimeout(this.timer)
    this.element.classList.remove("animate-toast-in")
    this.element.classList.add("animate-toast-out")
    this.element.addEventListener("animationend", () => this.element.remove(), { once: true })
  }
}