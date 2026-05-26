import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open()   { this.element.dataset.sidebarOpen = "true" }
  close()  { delete this.element.dataset.sidebarOpen }
  toggle() { this.element.dataset.sidebarOpen ? this.close() : this.open() }
}
