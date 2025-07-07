# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LogbookElix is a workout tracking application for weightlifters and bodybuilders. It's an Elixir/Phoenix JSON API backend that serves a React frontend. The app supports creating workouts, adding exercises, tracking sets with progressive overload, and managing custom exercises.

## Development Commands

### Database
- `docker-compose up -d` - Start PostgreSQL database (postgres:alpine, user/pass: postgres/postgres)
- `mix ecto.migrate` - Run database migrations  
- `mix ecto.setup` - Create database, run migrations, and seed data
- `mix ecto.reset` - Drop and recreate database completely

### Development Server
- `mix setup` - Install dependencies and setup database (first time setup)
- `mix phx.server` - Start Phoenix server (runs on localhost:4000)
- `mix compile` - Check compilation and fix any warnings
- Server auto-reloads on code changes, never restart manually

### Testing
- `mix test` - Run all tests (creates/migrates test database automatically)
- `mix test --failed` - Run only previously failed tests
- `mix test --stale` - Run tests for changed modules only

## Architecture

### Core Structure
- **Phoenix 1.7.21** JSON API (no HTML views)
- **PostgreSQL** database with UTC timestamps
- **Ecto** for database operations
- **Bandit** HTTP server

### Context Organization
- `LogbookElix.Accounts` - User management (Google OAuth)
- `LogbookElix.Exercises` - Exercise definitions and management
- `LogbookElix.Workouts` - Workout sessions, exercise executions, and sets

### Database Schema Relationships
```
User (Google OAuth profile)
├── Exercises (created_by_user_id)
└── Workouts (user_id)
    └── ExerciseExecutions (workout_id, exercise_id, exercise_order)
        └── Sets (exercise_execution_id, weight, clean_reps, forced_reps)
```

### Key Design Patterns
- **Sets are managed through ExerciseExecutions** using `cast_assoc(:sets)` - no separate Set API
- **Workouts can include ExerciseExecutions** using `cast_assoc(:exercise_executions)`
- **Context functions preload associations** (workouts preload exercise_executions and sets)
- **UTC timestamps** used throughout (`--timestamps-type utc_datetime`)

## API Structure

### Available Endpoints
- `GET|POST|PUT|DELETE /api/exercises` - Exercise CRUD operations
- `GET|POST|PUT|DELETE /api/workouts` - Workout CRUD (with nested exercise_executions and sets)
- `GET|POST|PUT|DELETE /api/exercise_executions` - Exercise execution CRUD (with nested sets)

### Authentication (Not Yet Implemented)
- Google OAuth token verification endpoint planned
- JWT tokens with 3-hour expiration
- Most endpoints will require authentication except token verification

## Code Conventions

### Error Handling - CRITICAL
- **NEVER** use `try`, `catch`, or `rescue` - follow "let it crash" philosophy
- **ALWAYS** use `with` statements in controllers, **NEVER** include `else` clauses
- Let `FallbackController` handle all `{:error, ...}` tuples
- Functions return `{:ok, result}` or `{:error, reason}` tuples

### Ecto Query Style - MANDATORY
Always use `from()` macro syntax, never pipe-based queries:

```elixir
# ✅ Correct
from(w in Workout,
  where: w.user_id == ^user_id,
  preload: [exercise_executions: :sets],
  order_by: [desc: w.inserted_at]
)

# ❌ Wrong  
Workout
|> where([w], w.user_id == ^user_id)
|> preload([w], exercise_executions: :sets)
```

### Database Conventions
- Use `:text` for string columns in migrations (`:string` in schemas)
- Use `:jsonb` for JSON columns (`:map` in schemas) 
- Set defaults: `timestamps(default: fragment("now()"))`
- Avoid unnecessary preloads - only preload what's needed

### Controller Patterns
```elixir
def create(conn, %{"workout" => workout_params}) do
  user = Guardian.Plug.current_resource(conn)
  
  with {:ok, workout} <- Workouts.create_workout(workout_params, user.id) do
    conn
    |> put_status(:created)
    |> render("show.json", workout: workout)
  end
end
```

## Testing
- Uses **ExUnit** with database sandboxing
- Test files mirror source structure in `test/` directory
- Use **ExMachina** for test data factories
- Fix all compilation warnings during testing

## Important Notes
- **Module naming**: All modules start with `LogbookElix.` or `LogbookElixWeb.`
- **No try/catch/rescue**: Critical rule - use proper error handling patterns
- **Preloads**: Be selective - don't preload associations unnecessarily
- **Timestamps**: All database timestamps are UTC
- **API responses**: JSON only, use proper HTTP status codes

Reference @docs/project_description.md for the general project goals