# Terakoya Calendar & Class Management System

**A comprehensive Rails engine for managing leader-partner relationships, classes, and calendars with event booking workflows.**

---

## 🎯 Overview

Terakoya provides a complete dual-mode system where users can operate as both **Partners** (learners/participants) and **Leaders** (teachers/mentors). The system includes:

- **Dual-Mode Profiles**: Every user can be both a Partner and a Leader
- **Class Management**: Leaders create classes, Partners join them
- **Calendar System**: Integrated FullCalendar with event booking and approval workflows
- **Event Management**: Comprehensive event system with visibility scoping
- **Notes System**: Rich text notes for sessions and classes (Action Text ready)

---

## 🚀 Quick Start

### Installation

Add to your Gemfile:

```ruby
gem 'terakoya', path: 'path/to/terakoya'
gem 'devise'  # Required for authentication
```

Install and configure:

```bash
bundle install
rails generate devise:install
rails generate devise User
rails generate terakoya:install
rails terakoya:install:migrations
rails db:migrate
```

Mount in `config/routes.rb`:

```ruby
mount Terakoya::Engine => '/terakoya'
```

### Requirements

- **Rails**: 8.0+
- **Ruby**: 3.2+
- **Database**: PostgreSQL (required for JSONB support)
- **Authentication**: Devise (or compatible)

---

## 📚 Core Concepts

### Dual-Mode System

Users can switch between two modes at any time:

**Partner Mode** (🎓):
- Join classes
- Book time slots on leader calendars
- View personal calendar
- Create notes and projects
- See class events and materials

**Leader Mode** (👨‍🏫):
- Create and manage classes
- Manage availability calendar
- Approve/decline booking requests
- Set working hours and booking rules
- View all partners across classes

Toggle modes via the dashboard switcher (stored in session).

### Data Model

```
User (from host app)
  ├─> Partner (polymorphic)
  │    ├─> Calendar
  │    ├─> ClassMemberships
  │    ├─> Classes (through memberships)
  │    └─> Events (as creator or participant)
  │
  └─> Leader (polymorphic)
       ├─> Calendar
       ├─> Classes (as owner)
       ├─> Events (as creator)
       └─> Partners (through classes)
```

---

## 🏗️ Architecture

### Models

#### Leader (`Terakoya::Leader`)

Represents a user in leader mode.

**Key Attributes**:
- `display_name` - How the leader appears to partners
- `bio` - Leader's background and experience
- `expertise` - Array of skill areas
- `accepting_partners` - Whether accepting new partners
- `max_partners` - Maximum partner capacity
- `availability_rules` - JSONB for scheduling preferences

**Associations**:
```ruby
has_one :calendar
has_many :classes
has_many :partners, through: :classes
```

**Key Methods**:
```ruby
leader.can_accept_partners?  # Check if accepting new partners
leader.upcoming_events       # Next events on calendar
leader.pending_approvals     # Events awaiting approval
```

#### Partner (`Terakoya::Partner`)

Represents a user in partner mode.

**Key Attributes**:
- `display_name` - Display name
- `bio` - About the partner
- `goals` - Learning objectives
- `timezone` - Partner's timezone

**Associations**:
```ruby
has_one :calendar
has_many :class_memberships
has_many :classes, through: :class_memberships
has_many :leaders, through: :classes
```

**Key Methods**:
```ruby
partner.active_classes       # Currently enrolled classes
partner.upcoming_events      # Upcoming events
partner.can_join_class?(cls) # Check if can join a class
```

#### Class (`Terakoya::Class`)

Groups that unite leaders and partners.

**Key Attributes**:
- `name` - Class name
- `description` - What the class is about
- `slug` - URL-friendly identifier (auto-generated)
- `status` - draft/active/paused/archived
- `visibility` - public/private/unlisted
- `capacity` - Max partners (nil for unlimited)
- `current_members` - Current member count
- `color` - Hex color for UI display

**Associations**:
```ruby
belongs_to :leader
has_many :class_memberships
has_many :partners, through: :class_memberships
has_many :events
has_many :notes
```

**Key Methods**:
```ruby
klass.can_accept_members?   # Check capacity
klass.add_partner(partner)  # Add a partner
klass.remove_partner(partner) # Remove a partner
klass.active_partners       # Active members
klass.calendar              # Access leader's calendar
```

#### Calendar (`Terakoya::Calendar`)

One calendar per user (automatically created).

**Key Attributes**:
- `calendar_type` - "leader" or "partner"
- `timezone` - Calendar timezone
- `default_event_duration` - Default event length (minutes)
- `buffer_time` - Time between events
- `advance_booking_days` - How far ahead partners can book
- `minimum_notice_hours` - Minimum advance notice required
- `work_hours` - JSONB for availability settings
- `booking_rules` - JSONB for custom rules

**Key Methods**:
```ruby
calendar.upcoming_events           # Future events
calendar.events_for_date(date)     # Events on specific date
calendar.is_available?(start, end) # Check availability
```

#### Event (`Terakoya::Event`)

Calendar events with comprehensive features.

**Core Attributes**:
- `title`, `description`, `location`
- `start_time`, `end_time`, `duration_minutes`
- `event_type` - booking/class_session/office_hours/personal/block
- `visibility` - public/private/class_only/busy
- `status` - draft/pending/confirmed/cancelled/completed
- `capacity`, `current_attendees`

**Scheduling Attributes**:
- `buffer_before`, `buffer_after` - Time padding (minutes)
- `cancellation_deadline_hours` - Cancel deadline
- `reschedule_limit` - Max reschedule count
- `requires_approval` - Needs leader approval

**Meeting Attributes**:
- `meeting_link` - Zoom/Meet URL
- `meeting_provider` - zoom/google_meet/teams/custom
- `join_instructions` - Custom instructions

**Automation Attributes**:
- `reminder_offset_minutes` - When to send reminder
- `send_email_notifications` - Email toggle
- `recurring_rule` - iCal RRULE format
- `parent_event_id` - Link to recurring parent

**Future-Ready**:
- `price_cents`, `currency` - Monetization
- `feedback_rating`, `feedback_text` - Post-event feedback
- `tags` - Array for categorization
- `metadata` - JSONB for extensions

**Visibility System**:
```ruby
event.visible_to?(user_or_role)         # Can see event exists
event.full_details_visible_to?(user)    # Can see all details
event.masked_for?(user)                  # Show as "busy"
```

**State Management**:
```ruby
event.confirm!              # Approve event
event.cancel!(reason: "")   # Cancel event
event.complete!             # Mark completed
event.can_be_cancelled?     # Check if cancellable
```

**JSON Serialization**:
```ruby
event.as_full_json    # Full details for FullCalendar
event.as_masked_json  # Masked "busy" slot
```

#### EventParticipant (`Terakoya::EventParticipant`)

Tracks event attendance.

**Attributes**:
- `role` - organizer/attendee/optional
- `status` - pending/confirmed/declined/cancelled
- `invited_at`, `response_at`, `checked_in_at`

**Methods**:
```ruby
participant.confirm!   # Accept invitation
participant.decline!   # Decline invitation
participant.check_in!  # Mark as checked in
```

#### Note (`Terakoya::Note`)

Rich text notes for sessions and classes (Action Text ready).

**Attributes**:
- `title`, `content` (rich text)
- `visibility` - private/shared_with_class/public
- `status` - draft/published/archived
- `tags` - Array for organization

**Associations**:
```ruby
belongs_to :author, polymorphic: true
belongs_to :event (optional)
belongs_to :terakoya_class (optional)
has_rich_text :content  # Action Text
has_many_attached :attachments  # Active Storage
```

---

## 🎨 FullCalendar Integration

### Setup

FullCalendar 6.1 is loaded via importmap (no npm required):

```ruby
# config/importmap.rb
pin "@fullcalendar/core", to: "https://cdn.skypack.dev/@fullcalendar/core@6.1.10"
pin "@fullcalendar/daygrid", to: "https://cdn.skypack.dev/@fullcalendar/daygrid@6.1.10"
pin "@fullcalendar/timegrid", to: "https://cdn.skypack.dev/@fullcalendar/timegrid@6.1.10"
pin "@fullcalendar/interaction", to: "https://cdn.skypack.dev/@fullcalendar/interaction@6.1.10"
```

### Stimulus Controller

The calendar is powered by a Stimulus controller:

```javascript
// app/javascript/terakoya/controllers/calendar_controller.js
import { Calendar } from "@fullcalendar/core"

export default class extends Controller {
  static values = {
    eventsUrl: String,     // JSON endpoint for events
    createUrl: String,     // POST endpoint for creation
    updateUrl: String,     // PATCH endpoint for updates
    editable: Boolean,     // Can drag/drop
    selectable: Boolean    // Can select date range
  }
}
```

### Usage in Views

```erb
<div
  data-controller="calendar"
  data-calendar-events-url-value="<%= calendar_path(format: :json) %>"
  data-calendar-create-url-value="<%= events_path(format: :json) %>"
  data-calendar-update-url-value="<%= event_path(':id', format: :json) %>"
  data-calendar-editable-value="true"
  data-calendar-selectable-value="true"
>
  <div data-calendar-target="container"></div>
</div>
```

### Event Visibility & Masking

Events automatically mask based on visibility:

- **Public**: Everyone sees full details
- **Private**: Only creator and participants see details
- **Class Only**: Only class members see details
- **Busy**: Non-participants see "Busy" (time blocked, no details)

```ruby
# In CalendarsController#show
def events_json(events)
  events.map do |event|
    if event.full_details_visible_to?(current_role)
      event.as_full_json
    else
      event.as_masked_json
    end
  end
end
```

---

## 📝 Event Booking Workflow

### Partner Books Time

1. **Partner views Leader's calendar**
   ```ruby
   # Partner can see:
   # - Available slots (no events)
   # - Their own events (full details)
   # - Class events (full details if member)
   # - Other events (masked as "busy")
   ```

2. **Partner creates booking**
   ```ruby
   event = calendar.events.create(
     title: "1:1 Session",
     start_time: Time.current + 2.days,
     end_time: Time.current + 2.days + 1.hour,
     event_type: "booking",
     status: "pending",  # Auto-set if requires_approval
     requires_approval: true
   )
   ```

3. **Leader sees pending approval**
   ```ruby
   leader.pending_approvals
   # => [#<Event status="pending" ...>]
   ```

4. **Leader approves or declines**
   ```ruby
   event.confirm!  # Sets status to "confirmed"
   # OR
   event.cancel!(reason: "Not available")
   ```

5. **Partner receives confirmation**
   ```ruby
   event.status  # => "confirmed"
   # Email sent (if notifications enabled)
   ```

### Leader Creates Event

Leaders can create events directly (no approval needed):

```ruby
event = leader.calendar.events.create(
  title: "Office Hours",
  event_type: "office_hours",
  status: "confirmed",  # Auto-confirmed
  terakoya_class_id: klass.id
)
```

---

## 🔐 Authorization & Permissions

### Controller Helpers

Available in all Terakoya controllers:

```ruby
current_partner      # Current Partner record (if exists)
current_leader       # Current Leader record (if exists)
current_mode         # "partner" or "leader" (from session)
current_role         # Returns current_partner or current_leader based on mode
partner_mode?        # Boolean
leader_mode?         # Boolean

require_partner!     # Redirect if no partner profile
require_leader!      # Redirect if no leader profile
require_role!        # Redirect if neither role
```

### Model Visibility Methods

**Events**:
```ruby
event.visible_to?(current_role)
event.full_details_visible_to?(current_role)
event.masked_for?(current_role)
```

**Notes**:
```ruby
note.visible_to?(current_role)
note.editable_by?(current_role)
```

**Classes**:
```ruby
klass.can_accept_members?
partner.can_join_class?(klass)
```

---

## 🛠️ Configuration

Create an initializer `config/initializers/terakoya.rb`:

```ruby
Terakoya.configure do |config|
  # Which model represents users
  config.user_class = "User"

  # Authentication method to call
  config.authentication_method = :authenticate_user!

  # Method to get current user
  config.current_user_method = :current_user

  # Coach/admin class (optional)
  config.coach_class = "User"
  config.coach_scope = -> { User.where(role: "coach") }
end
```

---

## 📱 Routes

All routes are namespaced under the engine mount point:

```
GET    /terakoya                      # Dashboard (redirects based on mode)
POST   /terakoya/dashboard/switch_mode # Switch partner/leader mode

# Profiles
GET    /terakoya/partner/new          # Create partner profile
GET    /terakoya/leader/new           # Create leader profile

# Classes
GET    /terakoya/classes              # Browse all classes
GET    /terakoya/classes/:slug        # Class details
POST   /terakoya/classes/:slug/join   # Join class (partner)
POST   /terakoya/classes/:slug/leave  # Leave class (partner)
GET    /terakoya/classes/new          # New class (leader)

# Calendar & Events
GET    /terakoya/calendar             # View calendar
GET    /terakoya/calendar.json        # Calendar events (JSON API)
GET    /terakoya/events/:id           # Event details
POST   /terakoya/events               # Create event
POST   /terakoya/events/:id/confirm   # Approve event (leader)
POST   /terakoya/events/:id/cancel    # Cancel event

# Notes
GET    /terakoya/notes                # All notes
GET    /terakoya/notes/:id            # Note details
POST   /terakoya/notes                # Create note
```

---

## 🎨 Customization

### Styling

Terakoya uses Bootstrap 5 by default. Customize by overriding:

```css
/* app/assets/stylesheets/terakoya_custom.css */

.fc-event-booking {
  background-color: #your-color !important;
}

.class-card {
  border-left: 4px solid var(--class-color);
}
```

### Views

Override any view by creating a matching file in your app:

```
app/views/terakoya/
  ├── calendars/
  │   └── show.html.erb  # Override calendar view
  ├── classes/
  │   └── _form.html.erb # Override class form
  └── dashboard/
      └── partner_dashboard.html.erb
```

### I18n

All strings are in `config/locales/en.yml`. Override or add languages:

```yaml
# config/locales/terakoya.ja.yml
ja:
  terakoya:
    dashboard:
      welcome: "おかえりなさい、%{name}"
```

---

## 🧪 Testing

### Running Migrations Test

Create a test sandbox:

```bash
# In the gem directory
bin/sandbox

# This will:
# 1. Create a fresh Rails app
# 2. Install Devise
# 3. Install Terakoya
# 4. Run all migrations
# 5. Seed with a test user
```

Test credentials: `student@example.com` / `password`

### Model Tests

```ruby
# test/models/terakoya/event_test.rb
class EventTest < ActiveSupport::TestCase
  test "visibility masking for non-participants" do
    event = events(:class_session)
    other_partner = partners(:other)

    assert event.visible_to?(other_partner)
    assert event.masked_for?(other_partner)
    refute event.full_details_visible_to?(other_partner)
  end
end
```

---

## 📊 Database Schema Highlights

### JSONB Columns for Flexibility

Many models use JSONB for flexible data storage:

```ruby
# Calendar settings
{
  work_hours: {
    monday: { start: "09:00", end: "17:00" },
    tuesday: { start: "09:00", end: "17:00" }
  },
  booking_rules: {
    min_duration: 30,
    max_duration: 120,
    allowed_days: ["monday", "tuesday", "wednesday"]
  }
}

# Event metadata
{
  zoom_id: "123456789",
  recording_url: "https://...",
  custom_field: "value"
}
```

### Polymorphic Associations

User linkage is polymorphic for flexibility:

```ruby
# Partner belongs to User polymorphically
partner.user_type  # => "User"
partner.user_id    # => 123

# Works with any authentication system
leader.user_type   # => "AdminUser"
leader.user_id     # => 456
```

### Indexes for Performance

All critical lookups are indexed:

```ruby
# Events by calendar and time range
add_index :terakoya_events, [:calendar_id, :start_time]

# Events by status (for pending approvals)
add_index :terakoya_events, :status

# Polymorphic lookups
add_index :terakoya_leaders, [:user_type, :user_id], unique: true
```

---

## 🚀 Advanced Features

### Recurring Events

Events support iCal RRULE format:

```ruby
event = Event.create(
  title: "Weekly Office Hours",
  recurring_rule: "FREQ=WEEKLY;BYDAY=TU,TH;UNTIL=20251231T235959Z",
  recurring_until: Time.zone.parse("2025-12-31"),
  is_template: true
)

# Generate instances
event.create_recurring_instances
```

### Event Templates

Leaders can create reusable event templates:

```ruby
template = Event.create(
  title: "1:1 Session Template",
  duration_minutes: 60,
  event_type: "booking",
  is_template: true,
  metadata: {
    default_meeting_link: "https://zoom.us/j/xxx",
    default_instructions: "Join 5 minutes early"
  }
)

# Use template
event = template.dup
event.is_template = false
event.start_time = Time.current + 1.day
event.save
```

### Availability Calculation

```ruby
# Find available slots
calendar.available_slots(
  date: Date.tomorrow,
  duration: 60  # minutes
)
# => [
#   { start: "2025-01-23 09:00", end: "2025-01-23 10:00" },
#   { start: "2025-01-23 14:00", end: "2025-01-23 15:00" }
# ]
```

### Webhook Events

Terakoya fires ActiveSupport::Notifications:

```ruby
# config/initializers/terakoya.rb
ActiveSupport::Notifications.subscribe("terakoya.event.confirmed") do |name, start, finish, id, payload|
  event = payload[:event]
  # Send confirmation email
  EventMailer.confirmed(event).deliver_later
end

# Available events:
# - terakoya.event.created
# - terakoya.event.confirmed
# - terakoya.event.cancelled
# - terakoya.class.partner_joined
# - terakoya.class.partner_left
```

---

## 🔄 Migration from Student to Partner/Leader

If upgrading from an older Terakoya version with the `Student` model:

### Automatic Migration

The migration `20260116000009_update_projects_for_partners.rb` handles:

1. Removing `student_id` from projects
2. Adding polymorphic `owner` association
3. Adding `terakoya_class_id` for class projects

### Data Migration Script

```ruby
# lib/tasks/migrate_students.rake
namespace :terakoya do
  task migrate_students_to_partners: :environment do
    Terakoya::Student.find_each do |student|
      # Create Partner
      partner = Terakoya::Partner.create!(
        user: student.user,
        display_name: student.display_name,
        bio: student.bio,
        goals: student.goals,
        timezone: student.timezone,
        preferred_language: student.preferred_language,
        settings: student.preferences
      )

      # Migrate projects
      student.projects.update_all(
        owner_type: "Terakoya::Partner",
        owner_id: partner.id
      )

      puts "Migrated #{student.display_name}"
    end
  end
end
```

Run with: `rails terakoya:migrate_students_to_partners`

---

## 📖 Example Workflows

### 1. Setting Up a New Class

```ruby
# Leader creates class
leader = current_user.leader || current_user.create_leader(
  display_name: "Jane Smith",
  bio: "10 years teaching Ruby"
)

klass = leader.classes.create(
  name: "Ruby Fundamentals",
  description: "Learn Ruby from scratch",
  capacity: 10,
  visibility: "public",
  status: "active"
)

# Set up recurring office hours
klass.events.create(
  title: "Office Hours",
  event_type: "office_hours",
  recurring_rule: "FREQ=WEEKLY;BYDAY=WE",
  start_time: Time.zone.parse("2025-01-22 15:00"),
  end_time: Time.zone.parse("2025-01-22 16:00"),
  visibility: "class_only"
)
```

### 2. Partner Joins and Books Session

```ruby
# Partner joins class
partner = current_user.partner
klass.add_partner(partner)

# Partner books 1:1 time
event = leader.calendar.events.create(
  title: "1:1 Session with Jane",
  start_time: 2.days.from_now.change(hour: 14),
  end_time: 2.days.from_now.change(hour: 15),
  event_type: "booking",
  creator: partner,
  status: "pending",  # Awaits leader approval
  requires_approval: true
)

# Leader approves
event.confirm!

# After session, partner adds notes
note = event.notes.create(
  author: partner,
  title: "Session Notes - Jan 22",
  content: "Discussed closures and blocks...",
  visibility: "shared_with_class"
)
```

### 3. Leader Views Dashboard

```ruby
# Switch to leader mode
session[:terakoya_mode] = "leader"

# Dashboard data
{
  classes: leader.classes.active.count,
  total_partners: leader.current_partners_count,
  pending_approvals: leader.pending_approvals.count,
  upcoming_events: leader.upcoming_events.limit(10),
  this_week_sessions: leader.calendar.events_for_range(
    Time.current.beginning_of_week,
    Time.current.end_of_week
  )
}
```

---

## 🐛 Troubleshooting

### FullCalendar Not Loading

Check importmap configuration:

```ruby
# config/importmap.rb - ensure these are present
pin "@fullcalendar/core", to: "https://cdn.skypack.dev/@fullcalendar/core@6.1.10"
pin "@fullcalendar/daygrid", to: "https://cdn.skypack.dev/@fullcalendar/daygrid@6.1.10"
pin "@fullcalendar/timegrid", to: "https://cdn.skypack.dev/@fullcalendar/timegrid@6.1.10"
pin "@fullcalendar/interaction", to: "https://cdn.skypack.dev/@fullcalendar/interaction@6.1.10"
```

Include Stimulus application:

```erb
<!-- app/views/layouts/application.html.erb -->
<%= javascript_importmap_tags %>
```

### Calendar Not Creating on User Creation

Ensure callbacks are running:

```ruby
# Check if calendar exists
leader.calendar || leader.create_calendar!(calendar_type: "leader", timezone: "UTC")
```

### Events Not Visible

Check visibility settings:

```ruby
# Debug visibility
event.visibility              # => "class_only"
event.terakoya_class         # => #<Class...>
current_partner.classes.include?(event.terakoya_class)  # => true/false

event.full_details_visible_to?(current_partner)  # Should be true
```

### Mode Switching Not Working

Ensure session is persisted:

```ruby
# ApplicationController
def switch_mode(mode)
  if mode.in?(%w[partner leader])
    session[:terakoya_mode] = mode
  end
end

# Check current mode
session[:terakoya_mode]  # => "partner" or "leader"
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙏 Credits

- **FullCalendar**: Calendar UI (https://fullcalendar.io)
- **Bootstrap 5**: UI framework
- **Stimulus**: JavaScript framework
- **Rails**: Application framework

---

## 📞 Support

For issues or questions:
- GitHub Issues: https://github.com/yourusername/terakoya/issues
- Documentation: https://terakoya.dev

---

**Built with ❤️ for collaborative learning**
