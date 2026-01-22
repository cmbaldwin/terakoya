import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { registerControllers } from "@hotwired/stimulus-loading"

const application = Application.start()
application.debug = false
window.Stimulus = application

// Register all controllers
const controllers = import.meta.glob('./controllers/**/*_controller.js', { eager: true })
registerControllers(application, controllers)

export { application }
