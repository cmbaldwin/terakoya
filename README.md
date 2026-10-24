# Terakoya (寺子屋)

A Rails 8+ engine for collaborative learning with leader-partner relationships, classes, and integrated calendar scheduling.

## Philosophy

Terakoya embodies collaborative learning where:

- **Partners** (learners) choose their own projects and goals
- **Leaders** (teachers/mentors) guide and support, not dictate
- Learning happens through building real, tangible projects
- Flexible scheduling with integrated calendar booking
- Classes unite leaders and partners in learning communities
- There are no perfect conditions - we start today

## Current Status

**🎉 Major Update: Calendar & Class System** ✅

### Core Features
- ✅ **Dual-Mode System**: Users can be both Partners and Leaders
- ✅ **Class Management**: Leaders create classes, Partners join
- ✅ **Calendar Integration**: FullCalendar v6 with Stimulus
- ✅ **Event Booking**: Partners book time → Leaders approve
- ✅ **Event Visibility**: Smart masking (show "busy" without details)
- ✅ **Rich Notes**: Session notes with Action Text support
- ✅ **Project System**: Track learning projects (updated for new roles)

### Technical Stack
- **Frontend**: Bootstrap 5, Stimulus, FullCalendar 6.1
- **Backend**: Rails 8.0+, PostgreSQL with JSONB
- **Auth**: Devise integration (polymorphic user associations)
- **I18n**: English/Japanese translations

## Quick Start

### 1. Add to Gemfile

```ruby
gem "terakoya", path: 'path/to/terakoya'  # or from git
gem "devise"  # Required for authentication
```

### 2. Install

```bash
bundle install
rails generate devise:install
rails generate devise User
rails generate terakoya:install
rails terakoya:install:migrations
rails db:migrate
```

### 3. Mount Engine

In `config/routes.rb`:

```ruby
mount Terakoya::Engine => "/terakoya"
```

### 4. Visit and Create Profile

Navigate to `http://localhost:3000/terakoya` and create:
1. **Partner Profile**: To join classes and book sessions
2. **Leader Profile**: To create classes and manage calendar (optional)

🎉 You're ready to start learning collaboratively!

## Requirements

- **Ruby**: 3.2+
- **Rails**: 8.0+
- **Database**: PostgreSQL (required for JSONB columns)
- **Auth**: Devise (or compatible authentication)

## Configuration

Create an initializer at `config/initializers/terakoya.rb`:

```ruby
Terakoya.configure do |config|
  # Which model represents users (default: "User")
  config.user_class = "User"

  # Authentication method to call (default: :authenticate_user!)
  config.authentication_method = :authenticate_user!

  # Method to get current user (default: :current_user)
  config.current_user_method = :current_user

  # Optional: Coach/admin configuration
  config.coach_class = "User"
  config.coach_scope = ->(users) { users.where(role: "coach") }
end
```

**Note**: Terakoya works with any Devise-compatible authentication system via polymorphic associations.

## Features

### 🎯 Dual-Mode System

**Every user can be both:**
- **Partner Mode** 🎓: Join classes, book sessions, view calendar
- **Leader Mode** 👨‍🏫: Create classes, manage availability, approve bookings
- **Seamless Switching**: Toggle between modes from dashboard

### 📚 Class Management

- **Create Classes**: Leaders create learning communities
- **Join Classes**: Partners browse and join public/private classes
- **Class Pages**: View members, upcoming events, shared notes
- **Capacity Management**: Set max partners, see "full" indicators
- **Color Coding**: Visual organization with custom colors
- **Flexible Visibility**: Public, private, or unlisted classes

### 📅 Integrated Calendar

**Powered by FullCalendar 6.1:**
- **Multiple Views**: Month, week, day, agenda list
- **Drag & Drop**: Create events by selecting time ranges
- **Event Types**: Booking, class session, office hours, personal, blocked time
- **Smart Visibility**: Events show as "busy" to non-participants
- **Real-time Updates**: JSON API with instant calendar refresh

### 🎫 Event Booking Workflow

1. **Partner books** time on Leader's calendar
2. **Event pending** approval (if required)
3. **Leader approves** or declines
4. **Event confirmed** → both calendars updated
5. **Notifications** sent (email ready)

**Event Features:**
- Meeting links (Zoom, Meet, etc.)
- Buffer time before/after
- Cancellation deadlines
- Capacity limits
- Recurring events (RRULE support)
- Event templates
- Rich metadata (JSONB)

### 📝 Notes System

- **Session Notes**: Attach notes to events
- **Class Notes**: Share with entire class
- **Rich Text**: Action Text ready (Trix editor)
- **File Attachments**: Active Storage support
- **Visibility Controls**: Private, class-only, public
- **Draft Workflow**: Save drafts, publish when ready

### 📊 Project Management

- **Partner Projects**: Track learning goals
- **Class Projects**: Group collaborative work
- **Status Tracking**: Planning → Active → Completed
- **Progress Indicators**: Todo-based completion percentage

### 🎨 UI/UX

- **Bootstrap 5**: Modern, responsive design
- **Color-Coded**: Classes and events visually distinct
- **Breadcrumb Navigation**: Always know where you are
- **Mode Indicator**: Clear Partner/Leader mode display
- **Mobile Responsive**: Works on all devices

### 🔐 Security & Privacy

- **Event Masking**: Non-participants see "busy" slots
- **Scoped Queries**: Users only see authorized data
- **Authorization Checks**: Every controller action protected
- **CSRF Protection**: Rails security built-in

### 🌍 Internationalization

- **English**: Full translation
- **Japanese**: 日本語対応
- **Extensible**: Easy to add more languages

### Coming Soon

- **Email Notifications**: Booking confirmations, reminders
- **Invitation Links**: Auto-signup with leader assignment
- **Availability Slots**: Leaders set specific available times
- **Calendar Export**: iCal format download
- **Real-time Updates**: Turbo Streams for live calendar
- **Video Integration**: Embedded Zoom/Meet sessions
- **Payment Integration**: Paid sessions support
- **Analytics Dashboard**: Session stats and insights

## Requirements

- Ruby >= 3.2
- Rails >= 8.0
- PostgreSQL (required for JSONB columns)
- Devise (for authentication)

## Usage Examples

### As a Partner (Learner)

```ruby
# 1. Create partner profile (via UI or programmatically)
partner = current_user.create_partner(
  display_name: "Alex Chen",
  bio: "Learning Ruby and Rails",
  goals: "Build a SaaS application",
  timezone: "America/Los_Angeles"
)

# 2. Browse and join classes
klass = Terakoya::Class.find_by(slug: "ruby-fundamentals")
klass.add_partner(partner)

# 3. View leader's calendar and book time
leader = klass.leader
available_slots = leader.calendar.available_slots(Date.tomorrow, duration: 60)

# 4. Create booking request
event = leader.calendar.events.create(
  title: "1:1 Session",
  start_time: available_slots.first[:start],
  end_time: available_slots.first[:end],
  event_type: "booking",
  creator: partner,
  status: "pending"  # Awaits leader approval
)

# 5. After session, add notes
note = event.notes.create(
  author: partner,
  title: "Session Notes",
  content: "Learned about ActiveRecord associations...",
  visibility: "shared_with_class"
)
```

### As a Leader (Teacher/Mentor)

```ruby
# 1. Create leader profile
leader = current_user.create_leader(
  display_name: "Jane Smith",
  bio: "10 years teaching Ruby",
  expertise: ["Ruby", "Rails", "PostgreSQL"],
  accepting_partners: true,
  max_partners: 20
)

# 2. Create a class
klass = leader.classes.create(
  name: "Ruby Fundamentals",
  description: "Learn Ruby from scratch",
  capacity: 10,
  visibility: "public",
  status: "active",
  color: "#3788d8"
)

# 3. Set up recurring office hours
klass.events.create(
  title: "Weekly Office Hours",
  event_type: "office_hours",
  recurring_rule: "FREQ=WEEKLY;BYDAY=WE",
  start_time: Time.zone.parse("15:00"),
  end_time: Time.zone.parse("16:00"),
  visibility: "class_only"
)

# 4. Review and approve booking requests
leader.pending_approvals.each do |event|
  event.confirm!  # or event.cancel!(reason: "Not available")
end

# 5. View dashboard stats
{
  total_classes: leader.classes.active.count,
  total_partners: leader.current_partners_count,
  pending_approvals: leader.pending_approvals.count,
  upcoming_events: leader.upcoming_events.this_week.count
}
```

### Mode Switching

```ruby
# In your controller
def switch_mode
  session[:terakoya_mode] = params[:mode]  # "partner" or "leader"
  redirect_to dashboard_path
end

# In views
<% if partner_mode? %>
  <%= render "partner_navigation" %>
<% elsif leader_mode? %>
  <%= render "leader_navigation" %>
<% end %>
```

## Architecture

### Data Model Overview

```
┌─────────────────────────────────────────────────┐
│                     User                        │
│              (Host Application)                 │
└────────────┬─────────────────────┬──────────────┘
             │                     │
             │ polymorphic         │ polymorphic
             ▼                     ▼
    ┌────────────────┐    ┌────────────────┐
    │    Partner     │    │     Leader     │
    │   (Learner)    │    │  (Teacher)     │
    └────────┬───────┘    └────────┬───────┘
             │                     │
             │                     │ has_many
             │                     ▼
             │            ┌────────────────┐
             │            │     Class      │◄──┐
             │            └────────┬───────┘   │
             │                     │           │
             │ join via            │ has_many  │
             │ ClassMembership     │           │
             └─────────────────────┘           │
                                               │
             ┌─────────────────────────────────┘
             │
             │ has_many
             ▼
    ┌────────────────┐
    │    Calendar    │
    └────────┬───────┘
             │ has_many
             ▼
    ┌────────────────┐     ┌──────────────────┐
    │     Event      │────▶│ EventParticipant │
    └────────┬───────┘     └──────────────────┘
             │ has_many
             ▼
    ┌────────────────┐
    │      Note      │
    └────────────────┘
```

### Key Design Decisions

**1. Polymorphic User Association**
- Partners and Leaders link to any User model
- Works with Devise, Clearance, or custom auth
- Flexible: `user_type` can be "User", "AdminUser", etc.

**2. Dual-Mode, Not Dual-Account**
- One user can have both Partner and Leader profiles
- Mode stored in session (not in database)
- Seamless switching without re-authentication

**3. Calendar per Role**
- Each Partner gets a calendar (personal events)
- Each Leader gets a calendar (availability + bookings)
- Separate calendars prevent conflicts

**4. Event Visibility Scoping**
- Public: Everyone sees details
- Private: Only creator and participants
- Class Only: Class members only
- Busy: Time shown, details hidden (privacy)

**5. JSONB for Flexibility**
- Settings, metadata, rules stored as JSON
- Extend without migrations
- Query with PostgreSQL JSON operators

**6. Engine Architecture**
- Isolated namespace `Terakoya::`
- Mountable at any path
- Migrations copied to host app
- Views overridable by host app

### Event Lifecycle

```
┌──────────────────────────────────────────────────┐
│                  Event Creation                   │
└──────────────────┬───────────────────────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
    Partner Creates      Leader Creates
         │                   │
         ▼                   ▼
    [status: pending]   [status: confirmed]
         │                   │
         ▼                   │
   Leader Reviews            │
         │                   │
    ┌────┴────┐              │
    │         │              │
Approve   Decline            │
    │         │              │
    ▼         ▼              │
[confirmed] [cancelled]      │
    │                        │
    └────────┬───────────────┘
             │
             ▼
      [Event Occurs]
             │
             ▼
       [completed]
             │
             ▼
      Notes Added
      Feedback Collected
```

## API Reference

See [CALENDAR_SYSTEM.md](./CALENDAR_SYSTEM.md) for comprehensive API documentation including:
- All model methods and associations
- Controller helpers and authorization
- FullCalendar Stimulus integration
- Event visibility rules
- Webhook events
- Advanced features (recurring events, templates, etc.)

## Development

### Setting up the Sandbox

To test Terakoya locally during development, use the sandbox script:

```bash
# Create the sandbox with PostgreSQL (default)
bin/sandbox

# Or explicitly specify database
DB=postgresql bin/sandbox
DB=mysql bin/sandbox
```

This creates a complete Rails application in the `sandbox/` directory with:

- Terakoya engine mounted at `/terakoya`
- Devise authentication configured
- Database migrations run
- Sample user: `student@example.com` / `password`

### Running the Sandbox

```bash
cd sandbox
bin/rails server
```

Visit http://localhost:3000/terakoya to access the engine.

### Running Tests

```bash
bundle exec rake test
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Built with ❤️ by [MOAB](https://moab.jp)
