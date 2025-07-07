# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Get Swole is a workout tracking web application for weightlifters and bodybuilders using progressive overload. This repository contains the **backend API** built with Elixir + Phoenix, serving a React frontend.

## Common Commands

```bash
# Setup and development
mix setup                    # Install dependencies and setup database
mix phx.server              # Start Phoenix server on localhost:4000
iex -S mix phx.server       # Start server with interactive Elixir shell

# Database operations
mix ecto.create             # Create database
mix ecto.migrate            # Run pending migrations
mix ecto.drop               # Drop database
mix ecto.reset              # Drop, create, and migrate database
mix ecto.setup              # Create, migrate, and seed database

# Testing
mix test                    # Run all tests
mix test --failed           # Run only failed tests
mix test test/path/to/test.exs  # Run specific test file

# Code generation
mix phx.gen.json Context Model table_name field:type  # Generate JSON API with context, schema, controller
mix phx.gen.schema Context Model table_name field:type  # Generate schema and migration only
```

## Architecture

### Data Model Hierarchy
The application follows a hierarchical workout structure with cascade deletes:
- **User** → **Workout** → **ExerciseExecution** → **Set**
- Deleting a workout removes all its exercise executions and sets
- Deleting an exercise execution removes all its sets

### Context Organization
Phoenix contexts organize related functionality:
- `LogbookElix.Accounts` - User management
- `LogbookElix.Workouts` - Workout CRUD operations  
- `LogbookElix.Executions` - Exercise execution management with Set cascade operations
- `LogbookElix.Sets` - Set schema (no direct API access)

### API Design
- **Users**: Read-only API except name updates (no create/delete via API)
- **Workouts**: Full CRUD operations
- **ExerciseExecutions**: Full CRUD with automatic Set handling via `cast_assoc`
- **Sets**: No direct API endpoints - managed through ExerciseExecution operations

### OpenAPI Integration
- OpenApiSpex generates API documentation from controller annotations
- API spec available at `/api/openapi`
- All controllers inherit OpenApiSpex behavior via `LogbookElixWeb` controller macro

### Authentication Flow (Future Implementation)
Frontend handles Google OAuth → Backend verifies Google token → Returns JWT for API access. JWT expires after 3 hours to avoid refresh token complexity.

## Database Schema Notes
- All models use UTC timestamps (`:utc_datetime`)
- Integer primary keys on all tables
- Foreign key constraints with appropriate cascade delete behavior
- `forced_reps` defaults to 0, `is_active` defaults to true

## Key Files
- `lib/logbook_elix_web/router.ex` - API route definitions
- `lib/logbook_elix_web/controllers/api_spec.ex` - OpenAPI specification
- `docs/project_plan.md` - Complete project requirements and frontend architecture
- `docs/models.md` - Original data model definitions