import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import dayGridPlugin from "@fullcalendar/daygrid"
import timeGridPlugin from "@fullcalendar/timegrid"
import interactionPlugin from "@fullcalendar/interaction"
import listPlugin from "@fullcalendar/list"

// Connects to data-controller="calendar"
export default class extends Controller {
  static targets = ["container"]
  static values = {
    eventsUrl: String,
    createUrl: String,
    updateUrl: String,
    editable: { type: Boolean, default: true },
    selectable: { type: Boolean, default: true }
  }

  connect() {
    this.initializeCalendar()
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
    }
  }

  initializeCalendar() {
    this.calendar = new Calendar(this.containerTarget, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
      initialView: "timeGridWeek",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay,listWeek"
      },
      editable: this.editableValue,
      selectable: this.selectableValue,
      selectMirror: true,
      dayMaxEvents: true,
      weekends: true,
      nowIndicator: true,
      slotMinTime: "06:00:00",
      slotMaxTime: "22:00:00",
      slotDuration: "00:30:00",
      height: "auto",

      // Event sources
      events: this.fetchEvents.bind(this),

      // Interaction handlers
      select: this.handleDateSelect.bind(this),
      eventClick: this.handleEventClick.bind(this),
      eventDrop: this.handleEventDrop.bind(this),
      eventResize: this.handleEventResize.bind(this),

      // Display
      eventDisplay: "block",
      eventTimeFormat: {
        hour: "2-digit",
        minute: "2-digit",
        meridiem: "short"
      }
    })

    this.calendar.render()
  }

  async fetchEvents(fetchInfo, successCallback, failureCallback) {
    try {
      const url = new URL(this.eventsUrlValue, window.location.origin)
      url.searchParams.append("start", fetchInfo.startStr)
      url.searchParams.append("end", fetchInfo.endStr)

      const response = await fetch(url, {
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken()
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const events = await response.json()
      successCallback(events)
    } catch (error) {
      console.error("Error fetching events:", error)
      failureCallback(error)
    }
  }

  handleDateSelect(selectInfo) {
    const title = prompt("Please enter event title:")
    const calendarApi = selectInfo.view.calendar

    calendarApi.unselect() // clear date selection

    if (title) {
      this.createEvent({
        title: title,
        start: selectInfo.startStr,
        end: selectInfo.endStr,
        allDay: selectInfo.allDay
      })
    }
  }

  async createEvent(eventData) {
    try {
      const response = await fetch(this.createUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({
          event: {
            title: eventData.title,
            start_time: eventData.start,
            end_time: eventData.end
          }
        })
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const event = await response.json()
      this.calendar.addEvent(event)
      this.showNotification("Event created successfully", "success")
    } catch (error) {
      console.error("Error creating event:", error)
      this.showNotification("Failed to create event", "error")
    }
  }

  handleEventClick(clickInfo) {
    const event = clickInfo.event

    // If event is masked (busy), don't show details
    if (event.extendedProps.masked) {
      this.showNotification("This time slot is busy", "info")
      return
    }

    // Show event details modal
    this.showEventDetails(event)
  }

  async handleEventDrop(dropInfo) {
    await this.updateEvent(dropInfo.event)
  }

  async handleEventResize(resizeInfo) {
    await this.updateEvent(resizeInfo.event)
  }

  async updateEvent(event) {
    try {
      const url = this.updateUrlValue.replace(":id", event.id)

      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({
          event: {
            start_time: event.start.toISOString(),
            end_time: event.end.toISOString()
          }
        })
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      this.showNotification("Event updated successfully", "success")
    } catch (error) {
      console.error("Error updating event:", error)
      this.showNotification("Failed to update event", "error")
      // Revert the event to its original state
      event.revert()
    }
  }

  showEventDetails(event) {
    // This will be enhanced with a proper modal
    const details = `
      Title: ${event.title}
      Start: ${event.start.toLocaleString()}
      End: ${event.end ? event.end.toLocaleString() : 'N/A'}
      ${event.extendedProps.description ? '\nDescription: ' + event.extendedProps.description : ''}
      ${event.extendedProps.location ? '\nLocation: ' + event.extendedProps.location : ''}
    `

    alert(details)
  }

  showNotification(message, type = "info") {
    // Simple notification - can be enhanced with a toast library
    console.log(`[${type.toUpperCase()}] ${message}`)

    // You can integrate with Rails flash messages or a toast library here
    const notification = document.createElement("div")
    notification.className = `alert alert-${type === "error" ? "danger" : type} alert-dismissible fade show`
    notification.setAttribute("role", "alert")
    notification.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    `

    const container = document.querySelector(".container") || document.body
    container.insertBefore(notification, container.firstChild)

    setTimeout(() => notification.remove(), 5000)
  }

  csrfToken() {
    return document.querySelector("[name='csrf-token']")?.content || ""
  }

  // Public methods that can be called from other controllers
  refetch() {
    if (this.calendar) {
      this.calendar.refetchEvents()
    }
  }

  changeView(viewName) {
    if (this.calendar) {
      this.calendar.changeView(viewName)
    }
  }

  today() {
    if (this.calendar) {
      this.calendar.today()
    }
  }

  next() {
    if (this.calendar) {
      this.calendar.next()
    }
  }

  prev() {
    if (this.calendar) {
      this.calendar.prev()
    }
  }
}
