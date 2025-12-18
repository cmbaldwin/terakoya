# Terakoya (寺子屋)

A Rails 8+ engine for project-based learning, inspired by traditional Japanese temple schools (寺子屋).

## Philosophy

Terakoya embodies student-directed learning where:

- Students choose their own projects and goals
- Teachers act as coaches and mentors, not authorities
- Learning happens through building real, tangible projects
- English immersion is encouraged but not required
- There are no perfect conditions - we start today

## Current Status

**Phase 1: MVP Complete** ✅

- Student and Project models with full CRUD
- Dashboard with Bootstrap 5 UI
- PostgreSQL with JSONB support for flexible metadata
- Devise authentication integration
- Sandbox development environment
- I18n support (English/Japanese)
- Dynamic motivational quotes in footer

## Installation

Add this line to your application's Gemfile:

```ruby
gem "terakoya"
```

And then execute:

```bash
bundle install
```

Run the installer:

```bash
rails terakoya:install:migrations
rails db:migrate
```

Mount the engine in your `config/routes.rb`:

```ruby
mount Terakoya::Engine => "/terakoya"
```

**Important**: Terakoya requires PostgreSQL due to JSONB column usage for flexible metadata storage.

## Configuration

Create an initializer at `config/initializers/terakoya.rb`:

```ruby
Terakoya.configure do |config|
  config.user_class = "User"
  config.coach_class = "User"
  config.coach_scope = ->(users) { users.where(role: "coach") }
end
```

**Authentication**: Terakoya integrates with your existing Devise authentication. Ensure your User model has Devise configured before mounting the engine.

## Features

### Currently Available (Phase 1)

- **Project Management**: Students create and manage their own learning projects
- **Student Profiles**: Polymorphic association with your User model
- **Dashboard**: Overview of active and completed projects
- **Bootstrap 5 UI**: Responsive, modern interface
- **I18n Support**: English and Japanese translations

### Coming Soon

- **Real-time Chat**: Built with Turbo Streams for instant communication (Phase 2)
- **Rich Notes**: Write and share notes with rich text formatting (Phase 3)
- **Todo Lists**: Track tasks and milestones (Phase 3)
- **Resource Library**: Upload files and save links (Phase 3)
- **Reminders**: Schedule check-ins and deadlines (Phase 4)
- **Full Export**: Download entire projects for portfolios (Phase 5)

## Requirements

- Ruby >= 3.2
- Rails >= 8.0
- PostgreSQL (required for JSONB columns)
- Devise (for authentication)

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
