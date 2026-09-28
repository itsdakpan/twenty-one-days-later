import { Controller } from "@hotwired/stimulus"

// Adds a like to a comment.
export default class extends Controller {
  static targets = ["count", "button"]
  static values = { url: String }

  async like() {
    this.buttonTarget.disabled = true
    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        }
      })
      if (!response.ok) throw new Error(`Like failed: ${response.status}`)
      const data = await response.json()
      this.countTarget.textContent = data.likes
      this.buttonTarget.classList.add("liked")
      this.buttonTarget.querySelector("i").classList.replace("fa-regular", "fa-solid")
    } finally {
      this.buttonTarget.disabled = false
    }
  }
}
