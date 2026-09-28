import { Controller } from "@hotwired/stimulus"

// Turns the plain multi-select into a searchable picker. Tom Select is loaded globally in the layout.
export default class extends Controller {
  connect() {
    if (typeof TomSelect === "undefined") return
    this.select = new TomSelect(this.element, {
      plugins: ["remove_button"],
      create: false,
      persist: false,
      placeholder: this.element.getAttribute("placeholder")
    })
  }

  disconnect() {
    this.select?.destroy()
  }
}
