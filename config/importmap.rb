# Pin npm packages by running ./bin/importmap

# Stimulus and Turbo (Rails defaults)
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# FullCalendar dependencies
pin "@fullcalendar/core", to: "https://cdn.skypack.dev/@fullcalendar/core@6.1.10"
pin "@fullcalendar/daygrid", to: "https://cdn.skypack.dev/@fullcalendar/daygrid@6.1.10"
pin "@fullcalendar/timegrid", to: "https://cdn.skypack.dev/@fullcalendar/timegrid@6.1.10"
pin "@fullcalendar/interaction", to: "https://cdn.skypack.dev/@fullcalendar/interaction@6.1.10"
pin "@fullcalendar/list", to: "https://cdn.skypack.dev/@fullcalendar/list@6.1.10"

# Terakoya application
pin "terakoya/application", to: "terakoya/application.js"
pin_all_from File.expand_path("../app/javascript/terakoya/controllers", __dir__), under: "controllers", to: "terakoya/controllers"
