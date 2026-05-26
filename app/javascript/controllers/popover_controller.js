import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "menu" ]

  connect() {
    this._onDocClick = (event) => {
      if (!this.element.contains(event.target)) this.close()
    }
    this._onKeydown = (event) => {
      if (event.key === "Escape") this.close()
    }
    document.addEventListener("click", this._onDocClick)
    document.addEventListener("keydown", this._onKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this._onDocClick)
    document.removeEventListener("keydown", this._onKeydown)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.menuTarget.hidden ? this.open() : this.close()
  }

  open()  { this.menuTarget.hidden = false }
  close() { this.menuTarget.hidden = true }
}