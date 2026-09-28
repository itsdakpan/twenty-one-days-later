import { Controller } from "@hotwired/stimulus"

// Fetches the quote of the day. Hides itself if the quote service is down.
export default class extends Controller {
  static targets = ["quote", "author", "loading"]

  async connect() {
    try {
      const response = await fetch("/quotes/random", { headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error(`Quote request failed: ${response.status}`)
      const data = await response.json()

      this.quoteTarget.textContent = `"${data.quote}"`
      this.authorTarget.textContent = data.author
      this.loadingTarget.remove()
    } catch (error) {
      this.element.hidden = true
    }
  }
}
