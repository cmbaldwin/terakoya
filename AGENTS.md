# Claude Development Guide for Terakoya

This document provides guidance for Claude Code when working on the Terakoya project.

## Project Overview

Terakoya (寺子屋) is a project-based learning platform built with Ruby on Rails. It helps track students' progress through hands-on projects, providing a structured learning environment with real-time feedback.

**Tech Stack:**
- Ruby on Rails 8.0
- PostgreSQL with JSONB support
- Bootstrap 5 (via CDN)
- Devise for authentication
- Hotwire (Turbo + Stimulus)

**Key Features:**
- Student and Project CRUD operations
- Dashboard with progress tracking
- Flexible metadata storage using JSONB
- Modern responsive UI

## Documentation Search with qmd

This project is indexed with `qmd`, a powerful documentation search tool that enables semantic search across all markdown files.

### Quick Search Commands

**Full-text search (BM25):**
```bash
qmd search "your query" -c terakoya
```

**Vector similarity search:**
```bash
qmd vsearch "semantic query" -c terakoya
```

**Combined search with query expansion and reranking:**
```bash
qmd query "your question" -c terakoya
```

**List all indexed files:**
```bash
qmd ls terakoya
```

**Get a specific file:**
```bash
qmd get qmd://terakoya/README.md
```

### When to Use qmd

Use qmd to quickly find relevant documentation when you need to:
- Understand project architecture or conventions
- Find examples of existing implementations
- Locate configuration files or setup instructions
- Search for technical decisions or patterns used in the project
- Find related documentation across multiple files

**Example use cases:**
- "How is authentication configured?" → `qmd query "authentication setup" -c terakoya`
- "What Bootstrap components are used?" → `qmd search "bootstrap" -c terakoya`
- "Find database schema information" → `qmd vsearch "database models schema" -c terakoya`

### Best Practices

1. **Use semantic search for concepts**: When looking for how something works conceptually, use `qmd vsearch` or `qmd query`
2. **Use text search for specifics**: When looking for exact terms or file names, use `qmd search`
3. **Combine with code search**: Use qmd for documentation, and Grep/Glob for source code
4. **Check multiple results**: Don't rely on just the top result - review a few matches to get complete context

## Project Structure

```
terakoya/
├── app/
│   ├── models/         # ActiveRecord models (Student, Project)
│   ├── controllers/    # Rails controllers
│   ├── views/          # ERB templates with Bootstrap 5
│   └── helpers/        # View helpers
├── config/
│   ├── routes.rb       # Application routes
│   └── database.yml    # PostgreSQL configuration
├── db/
│   ├── migrate/        # Database migrations
│   └── schema.rb       # Current schema
├── docs/               # Project documentation
├── sandbox/            # Development/testing environment
└── test/               # Test suite
```

## Development Workflow

### Running the Application

**Development server:**
```bash
bin/rails server
```

**Console:**
```bash
bin/rails console
```

**Database operations:**
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### Testing

Run tests before committing:
```bash
bin/rails test
```

### Code Style

- Follow Rails conventions and idioms
- Use JSONB for flexible metadata storage
- Leverage Bootstrap 5 utilities for styling
- Keep views simple using view helpers
- Use Stimulus for interactive components

## Key Implementation Patterns

### JSONB Metadata

Both Student and Project models use JSONB columns for flexible metadata:
```ruby
# Store arbitrary data in metadata column
student.metadata = { preferences: { theme: 'dark' }, tags: ['beginner'] }
```

### Bootstrap 5 Integration

Bootstrap 5 is loaded via CDN (no asset compilation):
- Use Bootstrap utility classes in views
- Follow Bootstrap component patterns
- Responsive-first design approach

### Authentication

Devise handles user authentication:
- Standard Devise routes and helpers
- Customizable views in `app/views/devise/`

## Common Tasks

### Adding a New Model

1. Generate migration: `bin/rails g model ModelName field:type`
2. Run migration: `bin/rails db:migrate`
3. Add associations and validations
4. Create controller and views
5. Update routes

### Adding a New Feature

1. Search documentation first using qmd to understand existing patterns
2. Follow existing conventions in the codebase
3. Use Bootstrap components for UI consistency
4. Write tests for new functionality
5. Update documentation as needed

## Useful Resources

- Project README: [README.md](README.md)
- Initial setup guide: [docs/01-initial-setup.md](docs/01-initial-setup.md)
- Full project plan: [TERAKOYA.md](TERAKOYA.md)

## Notes for Claude

- **Always check documentation first**: Use `qmd search` or `qmd query` before making assumptions about how something works
- **Maintain consistency**: Follow established patterns for models, controllers, and views
- **Test changes**: Run the test suite after making modifications
- **Keep it simple**: Avoid over-engineering - this is an MVP focused on core functionality
- **Document decisions**: Update relevant .md files when making significant changes

## Updating This Guide

When you learn something new about the project that would be helpful for future sessions, update this file. Keep it concise and focused on actionable information.

Last updated: 2026-02-04
