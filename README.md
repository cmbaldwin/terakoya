# Terakoya (寺子屋)

A Rails engine for project-based learning, inspired by traditional Japanese temple schools.

## Philosophy

Terakoya embodies student-directed learning where:
- Students choose their own projects and goals
- Teachers act as coaches and mentors, not authorities
- Learning happens through building real, tangible projects
- English immersion is encouraged but not required
- There are no perfect conditions - we start today

## Installation

Add this line to your application's Gemfile:

```ruby
gem "terakoya"
```

And then execute:
```bash
$ bundle install
```

Run the installer:
```bash
$ rails terakoya:install:migrations
$ rails db:migrate
```

Mount the engine in your `config/routes.rb`:
```ruby
mount Terakoya::Engine => "/terakoya"
```

## Configuration

Create an initializer at `config/initializers/terakoya.rb`:

```ruby
Terakoya.configure do |config|
  config.user_class = "User"
  config.coach_class = "User"
  config.coach_scope = ->(users) { users.where(role: "coach") }
  config.authentication_method = :authenticate_user!
  config.current_user_method = :current_user
end
```

## Features

- **Project Management**: Students create and manage their own learning projects
- **Real-time Chat**: Built with Turbo Streams for instant communication
- **Rich Notes**: Write and share notes with rich text formatting
- **Todo Lists**: Track tasks and milestones
- **Resource Library**: Upload files and save links
- **Reminders**: Schedule check-ins and deadlines
- **Full Export**: Download entire projects for portfolios

## Requirements

- Ruby >= 3.2
- Rails >= 8.0
- PostgreSQL (recommended) or MySQL

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Built with ❤️ by [MOAB](https://moab.jp)
