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

### Test Framework: ExMachina + ExUnit

**Context**: This project uses ExMachina 2.8 for test data factories to handle complex entity relationships automatically.

**Pattern**: Use ExMachina's factory pattern instead of Phoenix fixtures for all test data creation.

#### ✅ Factory Setup
```elixir
# test/support/factory.ex
defmodule LogbookElix.Factory do
  use ExMachina.Ecto, repo: LogbookElix.Repo

  def user_factory do
    %User{
      email_address: sequence(:email, &"user-#{&1}@example.com"),
      google_id: sequence(:google_id, &"google-id-#{&1}"),
      is_active: true,
      name: sequence(:name, &"User #{&1}"),
      profile_image_url: "https://example.com/profile.jpg"
    }
  end

  def workout_factory do
    %Workout{
      user: build(:user),  # Automatically creates user relationship
      finished_at: ~U[2025-07-07 12:00:00Z]
    }
  end

  def exercise_execution_factory do
    %ExerciseExecution{
      workout: build(:workout),  # Creates user → workout → execution chain
      exercise: sequence(:exercise, &(&1 + 1)),
      exercise_order: sequence(:exercise_order, &(&1 + 1)),
      note: "Exercise note"
    }
  end
end
```

#### ✅ Test Data Creation Patterns
```elixir
# Context tests - compare essential fields, not exact equality
test "list_workouts/0 returns all workouts" do
  workout = insert(:workout)
  [found_workout] = Workouts.list_workouts()
  assert found_workout.id == workout.id
  assert found_workout.finished_at == workout.finished_at
  assert found_workout.user_id == workout.user_id
end

# Controller tests - use setup blocks for test data
describe "update workout" do
  setup do
    %{workout: insert(:workout)}  # ExMachina creates full dependency chain
  end

  test "renders workout when data is valid", %{conn: conn, workout: workout} do
    conn = put(conn, ~p"/api/workouts/#{workout}", workout: @update_attrs)
    assert %{"id" => id} = json_response(conn, 200)["data"]
  end
end

# Creating test data with specific attributes
test "create_workout/1 with valid data" do
  user = insert(:user)
  valid_attrs = params_for(:workout) |> Map.put(:user_id, user.id)
  assert {:ok, %Workout{} = workout} = Workouts.create_workout(valid_attrs)
end
```

#### ❌ Avoid These Anti-Patterns
```elixir
# DON'T: Use Phoenix fixtures - they break with foreign key relationships
defp workout_fixture(attrs \\ %{}) do
  # This fails because workout requires user_id
  {:ok, workout} = Workouts.create_workout(attrs)
  workout
end

# DON'T: Custom helper functions in controller tests
defp create_user(_) do
  user = insert(:user)
  %{user: user}
end

# DON'T: Assert exact equality between ExMachina and context function results
assert Workouts.list_workouts() == [workout]  # Fails due to association loading differences
```

**Rationale**: ExMachina handles foreign key relationships automatically, creating realistic test data with proper dependency chains (User → Workout → ExerciseExecution → Set). Phoenix fixtures fail when schemas have required foreign keys.

### Test Data Guidelines
- Use `insert(:factory)` for persisted records that need database IDs
- Use `build(:factory)` for in-memory structs (faster, no DB calls)
- Use `params_for(:factory)` to get attribute maps for testing create functions
- Use sequences for unique values: `sequence(:field, &"value-#{&1}")`
- Create minimal test data - only what's needed for the specific test

### Test Organization
- Use ExUnit tests, not script files
- Mirror directory structure: test files should match functionality paths
- Import factory in each test file: `import LogbookElix.Factory`
- Run tests with various options: `--failed`, `--stale`, `--trace`, etc.
- Always fix compilation warnings during testing

### Association Loading in Tests
**Context**: ExMachina creates records with associations loaded, but context functions return unloaded associations.

**Pattern**: Compare specific fields instead of full record equality.
```elixir
# ✅ Compare essential fields
found_execution = Executions.get_exercise_execution!(exercise_execution.id)
assert found_execution.id == exercise_execution.id
assert found_execution.exercise == exercise_execution.exercise
assert found_execution.workout_id == exercise_execution.workout_id

# ❌ Don't compare full records
assert found_execution == exercise_execution  # Fails due to association loading
```

**Avoid**: Exact equality assertions between ExMachina-created records and context function results.

## Code Quality & Maintenance

### JWT Testing Patterns
**Context**: Testing JWT token verification requires parsing tokens and validating claims across multiple test files.

**Pattern**: Use shared test helpers for common JWT operations.
```elixir
# test/support/jwt_test_helper.ex
defmodule JwtTestHelper do
  def parse_jwt_header(token), do: # ... extract header logic
  def parse_jwt_claims(token), do: # ... extract claims logic  
  def extract_user_info_from_claims(claims), do: # ... user info extraction
end

# In test files
import JwtTestHelper
{:ok, claims} = parse_jwt_claims(@real_google_id_token)
user_info = extract_user_info_from_claims(claims)
```

**Rationale**: Eliminates code duplication across JWT-related tests and ensures consistent token parsing logic.

### Configuration Management
**Context**: External service URLs, cache configurations, and security settings need to be configurable.

**Pattern**: Extract magic strings and hardcoded values to module constants or application config.
```elixir
# ✅ Use module constants for service URLs
@google_certs_url "https://www.googleapis.com/oauth2/v1/certs"
@cache_name :google_certs_cache

# ✅ Make cache TTL configurable  
@cache_ttl Application.compile_env(:logbook_elix, :google_certs_cache_ttl, :timer.hours(1))

# ✅ Expose configuration through public functions when needed
def valid_issuers, do: @valid_issuers
```

**Avoid**: Hardcoded URLs, cache keys, and timeouts scattered throughout code without clear configuration strategy.

### Security Validation Patterns  
**Context**: Authentication tokens require validation of expiration, issuer, and other security claims.

**Pattern**: Clearly document security validations that are disabled for testing.
```elixir
defp validate_expiration(exp) when is_integer(exp) do
  # NOTE: Expiration validation is disabled for testing purposes.
  # In production, implement proper expiration checking.
  :ok
end
```

**Avoid**: Commented-out security code without clear documentation about production requirements.

### Dead Code Management
**Context**: During development, placeholder code and comments can accumulate.

**Pattern**: Regularly remove commented-out code, unused imports, and placeholder functions.
```elixir
# ❌ Remove these
# Start a worker by calling: LogbookElix.Worker.start_link(arg)  
# {LogbookElix.Worker, arg},

# ✅ Keep only active configuration
{Cachex, name: :google_certs_cache},
LogbookElixWeb.Endpoint
```

**Rationale**: Dead code creates confusion about system functionality and clutters the codebase.

## Key Files
- `lib/logbook_elix_web/router.ex` - API route definitions
- `lib/logbook_elix_web/controllers/api_spec.ex` - OpenAPI specification  
- `lib/logbook_elix/auth/google_token_verifier.ex` - Google OAuth token verification
- `test/support/factory.ex` - ExMachina factories for test data
- `test/support/jwt_test_helper.ex` - Shared JWT testing utilities
- `docs/project_plan.md` - Complete project requirements and frontend architecture
- `docs/models.md` - Original data model definitions

## Development Workflow Lessons

### Test Failures from Schema Changes
**Context**: When adding foreign key relationships to existing schemas, autogenerated Phoenix fixtures will fail.

**Pattern**: Always migrate to ExMachina factories when introducing foreign key constraints.
```bash
# When tests fail with "can't be blank" foreign key errors:
1. Add ExMachina dependency: {:ex_machina, "~> 2.8", only: :test}
2. Create factory.ex with relationship handling
3. Update all test files to import and use factories
4. Remove old fixture files
```

**Rationale**: Phoenix generators create fixtures assuming standalone entities, but real applications have complex relationships that require proper dependency chains.

### Quality Analysis Integration  
**Context**: Code quality should be monitored regularly to prevent accumulation of technical debt.

**Pattern**: Use quality analysis commands to identify maintainability issues:
- Dead code (unused variables, commented blocks)
- Code duplication (repeated logic across files)  
- Magic strings/numbers (hardcoded values)
- Poor naming conventions

**Avoid**: Allowing quality issues to accumulate - address them during feature development rather than in separate cleanup phases.