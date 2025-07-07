# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Get Swole is a workout tracking web application for weightlifters and bodybuilders using progressive overload. This repository contains the **backend API** built with Elixir + Phoenix, serving a React frontend.

## Common Commands

```bash
# Setup and development
mix setup                    # Install dependencies and setup database
mix compile                  # Check compilation (server auto-recompiles on requests)

# Database operations
mix ecto.create             # Create database
mix ecto.migrate            # Run pending migrations
mix ecto.drop               # Drop database
mix ecto.reset              # Drop, create, and migrate database
mix ecto.setup              # Create, migrate, and seed database

# Testing
mix test                    # Run all tests
mix test --failed           # Run only failed tests
mix test --stale            # Run only tests for changed modules
mix test test/path/to/test.exs  # Run specific test file

# Code generation
mix phx.gen.json Context Model table_name field:type  # Generate JSON API with context, schema, controller
mix phx.gen.schema Context Model table_name field:type  # Generate schema and migration only
mix ecto.gen.migration description  # Create migration file
```

## Development Guidelines

### Server Management
- **NEVER** start the server with `mix phx.server` or `iex -S mix phx.server` - assume it's already running
- **NEVER** run standalone `iex` sessions
- Server auto-recompiles on web requests, no restart needed
- Use `mix compile` to check compilation and fix any warnings

### Module Naming
- All modules must start with `Logbook.` or `LogbookWeb.`

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

## Error Handling

### Core Principle: "Let it Crash"
- Functions should return `{:error, "error_reason"}` when errors are expected
- **NEVER** use `try`, `catch`, or `rescue` - let unexpected errors crash the process
- Elixir processes are isolated; crashes don't corrupt other processes
- Supervisors restart crashed processes automatically

### Controller Error Handling
- **MANDATORY**: Use `with` statements for all business logic operations
- **NEVER** include `else` clauses in `with` statements
- **NEVER** use `case` statements for error handling in controller actions
- **NEVER** manually handle `{:error, ...}` tuples in controller actions
- All controller actions must declare `action_fallback LogbookElixWeb.FallbackController`

#### ✅ Correct Controller Pattern
```elixir
def create(conn, %{"workout" => workout_params}) do
  user = Guardian.Plug.current_resource(conn)

  with {:ok, workout} <- Workouts.create_workout(workout_params, user.id) do
    conn
    |> put_status(:created)
    |> render(:show, workout: workout)
  end
end
```

## Database Development

### Ecto Query Style
Use `from()` macro syntax for all queries instead of pipe-based approach:

#### ✅ Preferred Style
```elixir
def list_workouts(user_id) do
  from(w in Workout,
    where: w.user_id == ^user_id,
    where: not is_nil(w.finished_at),
    preload: [:exercise_executions],
    order_by: [desc: w.finished_at]
  )
  |> Repo.all()
end
```

#### ❌ Avoid This Style
```elixir
def list_workouts(user_id) do
  Workout
  |> where([w], w.user_id == ^user_id)
  |> where([w], not is_nil(w.finished_at))
  |> preload([:exercise_executions])
  |> order_by([w], desc: w.finished_at)
  |> Repo.all()
end
```

### Query Guidelines
- Use meaningful variable names for bindings (e.g., `w` for Workout, `ee` for ExerciseExecution)
- Alias tables when reused: `as: :workout`
- Join using `assoc()` instead of `on` clauses when possible
- Avoid unnecessary preloads - only load what you need
- Never preload associations while mapping over lists
- Prefer selecting specific fields instead of whole schemas

### Migration Guidelines
- Group related changes into single migration files
- Always use `:text` for string columns (`:string` in schemas)
- Always use `:jsonb` for JSON columns (`:map` in schemas)
- Set default timestamps: `timestamps(default: fragment("now()"))`

## Testing

### Test Organization
- Use ExUnit tests, not script files
- Mirror directory structure: test files should match functionality paths
- Use ExMachina for test data setup
- Run tests with various options: `--failed`, `--stale`, `--trace`, etc.
- Always fix compilation warnings during testing

## Key Files
- `lib/logbook_elix_web/router.ex` - API route definitions
- `lib/logbook_elix_web/controllers/api_spec.ex` - OpenAPI specification
- `docs/project_plan.md` - Complete project requirements and frontend architecture
- `docs/models.md` - Original data model definitions