# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-16

### Added
- Initial gem structure with Rails 8 engine
- Student model with polymorphic user association
- Project model with status management (planning, active, paused, completed, archived)
- Student registration and profile management
- Project CRUD operations
- Dashboard view for students
- State transitions for projects (start, pause, resume, complete)
- I18n support for English and Japanese
- Basic styling with CSS custom properties
- Test suite with model tests
- Database migrations for students and projects

### Phase 1 MVP Complete
- [x] Gem skeleton with Rails engine
- [x] Student and Project models
- [x] Basic CRUD for projects
- [x] Student dashboard
- [x] Project dashboard view

### Coming in Phase 2
- [ ] Message model and chat interface
- [ ] Turbo Streams for real-time chat
- [ ] Rich text support
- [ ] Basic notifications
