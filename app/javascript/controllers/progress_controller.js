import { Controller } from "@hotwired/stimulus"

// Ticks days on the signed-in member's board and saves each change to the server.
export default class extends Controller {
  static targets = ["day", "count"]
  static values = { url: String, total: Number }

  async toggle(event) {
    const day = event.currentTarget
    const completed = !day.classList.contains("is-done")
    this.render(day, completed)

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({ day: day.dataset.day, completed })
      })
      if (!response.ok) throw new Error(`Save failed: ${response.status}`)
    } catch (error) {
      this.render(day, !completed)
      return
    }

    if (completed && this.doneCount === this.totalValue) this.celebrate()
  }

  render(day, completed) {
    day.classList.toggle("is-done", completed)
    day.setAttribute("aria-pressed", completed)
    if (completed) {
      day.classList.remove("pop")
      void day.offsetWidth
      day.classList.add("pop")
    }
    this.countTarget.textContent = this.doneCount
    const summary = document.querySelector("[data-progress-count]")
    if (summary) summary.textContent = `${this.doneCount}/${this.totalValue}`
  }

  get doneCount() {
    return this.dayTargets.filter((day) => day.classList.contains("is-done")).length
  }

  celebrate() {
    const overlay = document.createElement("div")
    overlay.className = "celebrate"
    overlay.innerHTML = `
      <div class="celebrate__card" role="dialog" aria-modal="true" aria-labelledby="celebrate-title">
        <div class="celebrate__badge">21</div>
        <h2 id="celebrate-title">All 21 days.</h2>
        <p>That's a habit now. Tell the group.</p>
        <button type="button" class="button">Close</button>
      </div>`
    overlay.addEventListener("click", (event) => {
      if (event.target === overlay || event.target.closest("button")) overlay.remove()
    })
    document.body.appendChild(overlay)
    overlay.querySelector("button").focus()
  }
}
