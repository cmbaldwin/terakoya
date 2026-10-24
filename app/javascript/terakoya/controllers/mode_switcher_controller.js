import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mode-switcher"
export default class extends Controller {
  static targets = ["button", "indicator"]
  static values = {
    currentMode: String,
    switchUrl: String
  }

  connect() {
    this.updateUI()
  }

  switch(event) {
    event.preventDefault()
    const newMode = event.currentTarget.dataset.mode

    if (newMode === this.currentModeValue) {
      return
    }

    this.switchMode(newMode)
  }

  async switchMode(mode) {
    try {
      const response = await fetch(this.switchUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({ mode: mode })
      })

      if (response.ok) {
        window.location.reload()
      } else {
        console.error("Failed to switch mode")
      }
    } catch (error) {
      console.error("Error switching mode:", error)
    }
  }

  updateUI() {
    this.buttonTargets.forEach(button => {
      const buttonMode = button.dataset.mode
      if (buttonMode === this.currentModeValue) {
        button.classList.add("active")
      } else {
        button.classList.remove("active")
      }
    })
  }

  csrfToken() {
    return document.querySelector("[name='csrf-token']")?.content || ""
  }
}
