# Terakoya (寺子屋) - Project-Based Learning Platform

## Name & Philosophy

**Terakoya** (寺子屋) - Named after the traditional Japanese temple schools that educated commoners during the Edo period. These schools were remarkable for their time: voluntary attendance, personalized instruction, and practical skill development. Our modern Terakoya carries this spirit forward.

### Core Philosophy

Informed by:
- **Karl Popper** - Knowledge grows through conjecture and refutation; learning is problem-solving
- **David Deutsch** - All problems are soluble given the right knowledge; creativity is the engine of progress
- **Sarah Fitz-Claridge & Taking Children Seriously** - Children are rational beings capable of directing their own learning; coercion undermines genuine understanding

### The Terakoya Approach

1. **Student-Directed** - The student chooses what to learn, with a tentative goal
2. **Project-Based** - At the end, they have something tangible to show
3. **English Immersion** - As much of the project as possible done in English (non-compulsory, encouraged)
4. **Coach/Mentor Model** - The teacher is a life coach and idea-bouncing resource, not an authority figure
5. **No Perfect Conditions** - Fear of failure is the only barrier. Let's start today.

---

## Gem Architecture

### Gem Name & Structure

```
terakoya/
├── lib/
│   ├── terakoya.rb                    # Main entry point
│   ├── terakoya/
│   │   ├── version.rb
│   │   ├── engine.rb                  # Rails engine
│   │   └── configuration.rb           # Configurable options
├── app/
│   ├── controllers/
│   │   └── terakoya/
│   │       ├── application_controller.rb
│   │       ├── projects_controller.rb
│   │       ├── students_controller.rb
│   │       ├── resources_controller.rb
│   │       ├── messages_controller.rb
│   │       ├── notes_controller.rb
│   │       ├── todos_controller.rb
│   │       └── reminders_controller.rb
│   ├── models/
│   │   └── terakoya/
│   │       ├── application_record.rb
│   │       ├── project.rb
│   │       ├── student.rb
│   │       ├── resource.rb
│   │       ├── message.rb
│   │       ├── note.rb
│   │       ├── todo.rb
│   │       └── reminder.rb
│   ├── views/
│   │   └── terakoya/
│   │       ├── layouts/
│   │       ├── projects/
│   │       ├── students/
│   │       ├── dashboard/
│   │       └── shared/
│   ├── javascript/
│   │   └── terakoya/
│   │       └── controllers/           # Stimulus controllers
│   │           ├── chat_controller.js
│   │           ├── todo_controller.js
│   │           ├── notes_controller.js
│   │           ├── reminder_controller.js
│   │           └── export_controller.js
│   └── assets/
│       └── stylesheets/
│           └── terakoya/
│               └── application.css
├── config/
│   ├── routes.rb
│   └── locales/
│       ├── en.yml
│       └── ja.yml
├── db/
│   └── migrate/
├── spec/ or test/
├── terakoya.gemspec
├── Gemfile
└── README.md
```

---

## Data Models

### Student
```ruby
# Terakoya::Student
# Links to host application's User model
create_table :terakoya_students do |t|
  t.references :user, polymorphic: true  # Links to host app's user
  t.string :display_name
  t.string :preferred_language, default: 'en'  # en, ja, both
  t.text :bio
  t.text :goals                          # Long-term goals
  t.string :timezone
  t.jsonb :preferences, default: {}
  t.timestamps
end
```

### Project
```ruby
# Terakoya::Project
create_table :terakoya_projects do |t|
  t.references :student, foreign_key: { to_table: :terakoya_students }
  t.string :title
  t.text :description
  t.text :goal                           # What they want to achieve
  t.text :deliverable                    # What they'll have at the end
  t.string :status, default: 'planning'  # planning, active, paused, completed, archived
  t.date :target_date                    # Optional target completion
  t.datetime :started_at
  t.datetime :completed_at
  t.jsonb :metadata, default: {}
  t.timestamps
end
```

### Resource
```ruby
# Terakoya::Resource
# Files, links, and materials for a project
create_table :terakoya_resources do |t|
  t.references :project, foreign_key: { to_table: :terakoya_projects }
  t.references :uploaded_by, polymorphic: true  # Student or coach
  t.string :title
  t.text :description
  t.string :resource_type                # file, link, video, document, code
  t.string :url                          # For external links
  t.jsonb :metadata, default: {}
  t.timestamps
end
# + Active Storage attachment for files
```

### Message
```ruby
# Terakoya::Message
# Chat between student and coach
create_table :terakoya_messages do |t|
  t.references :project, foreign_key: { to_table: :terakoya_projects }
  t.references :sender, polymorphic: true
  t.text :content
  t.boolean :read, default: false
  t.datetime :read_at
  t.jsonb :metadata, default: {}         # For reactions, edits, etc.
  t.timestamps
end
# + Action Text for rich content
```

### Note
```ruby
# Terakoya::Note
# Project notes (private or shared)
create_table :terakoya_notes do |t|
  t.references :project, foreign_key: { to_table: :terakoya_projects }
  t.references :author, polymorphic: true
  t.string :title
  t.boolean :shared, default: true       # Visible to both student and coach
  t.jsonb :metadata, default: {}
  t.timestamps
end
# + Action Text for rich content
```

### Todo
```ruby
# Terakoya::Todo
# Project tasks
create_table :terakoya_todos do |t|
  t.references :project, foreign_key: { to_table: :terakoya_projects }
  t.references :created_by, polymorphic: true
  t.references :assigned_to, polymorphic: true, null: true
  t.string :title
  t.text :description
  t.string :status, default: 'pending'   # pending, in_progress, completed, cancelled
  t.integer :position
  t.date :due_date
  t.datetime :completed_at
  t.jsonb :metadata, default: {}
  t.timestamps
end
```

### Reminder
```ruby
# Terakoya::Reminder
# Scheduled reminders for students/projects
create_table :terakoya_reminders do |t|
  t.references :project, foreign_key: { to_table: :terakoya_projects }
  t.references :created_by, polymorphic: true
  t.references :target, polymorphic: true  # Who receives reminder
  t.string :title
  t.text :message
  t.datetime :remind_at
  t.string :frequency                    # once, daily, weekly
  t.boolean :sent, default: false
  t.datetime :sent_at
  t.boolean :active, default: true
  t.jsonb :metadata, default: {}
  t.timestamps
end
```

---

## Key Features

### 1. Student Registration & Profile
- Self-service registration (connects to host app's auth)
- Profile with goals, bio, language preference
- Dashboard showing all projects

### 2. Project Dashboard
- Project overview with status, goal, deliverable
- Progress tracking
- Quick access to all project features
- Project timeline/history

### 3. Chat/Messaging
- Real-time chat using Turbo Streams
- Rich text support (Lexxy/Action Text)
- Message history
- Read receipts
- File sharing inline

### 4. Resources
- Upload files (images, documents, code)
- Save external links
- Categorize resources
- Full-text search

### 5. Notes
- Rich text notes (Lexxy)
- Private or shared visibility
- Tagging/organization

### 6. Todo List
- Create tasks with optional due dates
- Assign to student or coach
- Drag-and-drop reordering
- Status tracking

### 7. Reminders
- Schedule reminders for sessions
- Recurring reminders (daily check-ins, weekly reviews)
- Email/in-app notifications

### 8. Export
- Download entire project as ZIP
- Includes: all notes, resources, chat history, todos
- Formatted for portfolio use
- PDF report generation option

---

## Technical Implementation

### Rails 8 Compatibility

```ruby
# terakoya.gemspec
Gem::Specification.new do |spec|
  spec.name        = "terakoya"
  spec.version     = Terakoya::VERSION
  spec.authors     = ["MOAB"]
  spec.email       = ["hello@moab.jp"]
  spec.homepage    = "https://github.com/moab-jp/terakoya"
  spec.summary     = "Project-based learning platform for Rails 8"
  spec.description = "A drop-in Rails engine for student-directed, project-based learning with English immersion support."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "propshaft"
end
```

### Engine Configuration

```ruby
# lib/terakoya/engine.rb
module Terakoya
  class Engine < ::Rails::Engine
    isolate_namespace Terakoya

    # Importmap integration
    initializer "terakoya.importmap", before: "importmap" do |app|
      app.config.importmap.paths << Engine.root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << Engine.root.join("app/javascript")
    end

    # Stimulus controllers
    initializer "terakoya.stimulus" do |app|
      app.config.stimulus.paths << Engine.root.join("app/javascript/terakoya/controllers")
    end

    # Assets
    initializer "terakoya.assets" do |app|
      app.config.assets.precompile += %w[terakoya/application.css]
    end

    # Action Text support
    initializer "terakoya.action_text" do
      ActiveSupport.on_load(:action_text_rich_text) do
        # Rich text configuration
      end
    end
  end
end
```

### Host App Integration

```ruby
# config/routes.rb (host app)
Rails.application.routes.draw do
  mount Terakoya::Engine => "/terakoya"
end

# config/initializers/terakoya.rb (host app)
Terakoya.configure do |config|
  config.user_class = "User"
  config.coach_class = "User"  # Or separate Coach model
  config.coach_scope = ->(users) { users.where(role: "coach") }
  config.authentication_method = :authenticate_user!
  config.current_user_method = :current_user
end
```

### Stimulus Controllers

```javascript
// app/javascript/terakoya/controllers/chat_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "form"]
  static values = { projectId: Number }

  connect() {
    this.scrollToBottom()
  }

  submit(event) {
    event.preventDefault()
    // Turbo Stream handles the actual submission
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  // Called after Turbo Stream appends new message
  messageAdded() {
    this.scrollToBottom()
    this.inputTarget.value = ""
  }
}
```

### Turbo Streams for Real-time

```ruby
# app/controllers/terakoya/messages_controller.rb
module Terakoya
  class MessagesController < ApplicationController
    def create
      @message = @project.messages.build(message_params)
      @message.sender = current_user

      if @message.save
        # Broadcast to project channel
        Turbo::StreamsChannel.broadcast_append_to(
          "terakoya_project_#{@project.id}_messages",
          target: "messages",
          partial: "terakoya/messages/message",
          locals: { message: @message }
        )

        head :ok
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
end
```

---

## Implementation Phases

### Phase 1: Core Foundation (MVP)
- [ ] Gem skeleton with Rails engine
- [ ] Student and Project models
- [ ] Basic CRUD for projects
- [ ] Student dashboard
- [ ] Project dashboard view

### Phase 2: Communication
- [ ] Message model and chat interface
- [ ] Turbo Streams for real-time chat
- [ ] Rich text support with Lexxy
- [ ] Basic notifications

### Phase 3: Project Tools
- [ ] Notes with rich text
- [ ] Todo list with drag-and-drop
- [ ] Resource uploads and links
- [ ] File attachments in chat

### Phase 4: Scheduling & Reminders
- [ ] Reminder model
- [ ] Scheduled jobs for reminders
- [ ] Email notifications
- [ ] In-app notification center

### Phase 5: Export & Polish
- [ ] Full project export as ZIP
- [ ] PDF report generation
- [ ] Activity timeline
- [ ] Search across all content

### Phase 6: Enhancement
- [ ] Progress tracking/milestones
- [ ] Templates for common project types
- [ ] Analytics for coaches
- [ ] Mobile-responsive refinements

---

## Example Project Ideas

These will be featured in the launch blog post:

### Creative & Digital
1. **Create a Minecraft Mod** - Learn Java, game design, creative problem-solving
2. **Build a Roblox Game** - Lua programming, game design, user experience
3. **Start a Bilingual YouTube Channel** - Video production, scripting in English, audience engagement

### Maker & Physical
4. **3D Printing Projects** - CAD design, prototyping, iterative improvement
5. **Electronics/Arduino Project** - Basic circuits, programming, physical computing

### Content & Media
6. **Read & Review English Books** - Literature analysis, critical thinking, public speaking
7. **Movie Reviews in English** - Film analysis, vocabulary building, presentation skills
8. **Write a Short Story or Novel** - Creative writing, narrative structure, editing

### Technical
9. **Learn Programming with Claude Code** - Build real apps, problem-solving, modern AI tools
10. **Build a Personal Website** - HTML/CSS, self-expression, digital presence

### Academic & Research
11. **Scientific Research Project** - Pick an open problem, understand current knowledge, contribute
12. **History Deep Dive** - Research, primary sources, synthesis, presentation

### Life Skills
13. **Start a Small Business** - Planning, budgeting, marketing, customer service
14. **Learn an Instrument** - Practice discipline, music theory, performance

---

## Design Integration

The gem will ship with sensible defaults but allow full customization:

```ruby
# Use host app's styles
Terakoya.configure do |config|
  config.stylesheet = "application"  # Use host app CSS
  # OR
  config.stylesheet = "terakoya/application"  # Use bundled CSS
end
```

Bundled CSS will use CSS custom properties for easy theming:

```css
:root {
  --terakoya-primary: var(--bs-primary, #0d6efd);
  --terakoya-success: var(--bs-success, #198754);
  --terakoya-bg: var(--bs-body-bg, #fff);
  --terakoya-text: var(--bs-body-color, #212529);
  /* Falls back to Bootstrap if available, otherwise uses defaults */
}
```

---

## Testing Strategy

Following MOAB's testing philosophy:

```ruby
# test/models/terakoya/project_test.rb
require "test_helper"

module Terakoya
  class ProjectTest < ActiveSupport::TestCase
    test "project requires student" do
      project = Project.new(title: "Test")
      assert_not project.valid?
      assert_includes project.errors[:student], "must exist"
    end

    test "project transitions through statuses correctly" do
      project = create(:terakoya_project)
      assert_equal "planning", project.status

      project.start!
      assert_equal "active", project.status
      assert_not_nil project.started_at
    end
  end
end
```

---

## Localization

Full Japanese and English support:

```yaml
# config/locales/en.yml
en:
  terakoya:
    projects:
      new: "Start a New Project"
      goal: "What do you want to achieve?"
      deliverable: "What will you have to show at the end?"
    dashboard:
      welcome: "Welcome to your learning journey"
      no_projects: "Ready to start your first project? There are no perfect conditions."
```

```yaml
# config/locales/ja.yml
ja:
  terakoya:
    projects:
      new: "新しいプロジェクトを始める"
      goal: "何を達成したいですか？"
      deliverable: "最後に何を見せられますか？"
    dashboard:
      welcome: "学びの旅へようこそ"
      no_projects: "最初のプロジェクトを始めませんか？完璧な条件なんてありません。"
```

---

## Next Steps

1. **Create gem repository** - `moab-jp/terakoya` on GitHub
2. **Write blog post** - Announce the program, call for students
3. **Build Phase 1 MVP** - Core models and basic UI
4. **Integrate with MOAB site** - Mount engine, test integration
5. **Beta test** - Find first students, iterate on feedback

---

## Repository

**GitHub**: `github.com/moab-jp/terakoya`
**License**: MIT
**Gem**: `gem "terakoya"`

---

*"There is no perfect condition. Let's get started today."*
