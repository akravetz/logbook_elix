# Exercise Feature Implementation Plan

## Overview
Implementation of a comprehensive exercise management system that supports both system-provided exercises and user-created custom exercises.

## Tasks

### High Priority (Core Implementation)

#### ✅ 1. Generate Exercise schema, context, controller, and migration using phx.gen.json
- Run Phoenix generator to create basic CRUD structure
- Command: `mix phx.gen.json Exercises Exercise exercises name:string body_part:string modality:string is_system_created:boolean created_by_user_id:references:users`

#### ✅ 2. Update Exercise migration to add foreign key to users table and is_system_created field
- Modify migration to use `:text` for string columns (per project conventions)
- Add proper foreign key constraints with cascade rules
- Set default for `is_system_created` to `false`
- Add indexes for performance

#### ✅ 3. Update Exercise schema to define enums for body_part and modality
- Define Ecto enums for type safety
- Body parts: chest, back, legs, arms, core, shoulders, quads, glutes, hamstrings
- Modalities: barbell, dumbbell, cable, machine, bodyweight, other
- Add proper relationships to User

#### ✅ 4. Update Exercises context module to add authorization logic for CRUD operations
- Implement authorization patterns:
  - `list_exercises/1` - returns system exercises + user's exercises
  - `get_exercise/2` - validates user can access (system or own)
  - `create_exercise/2` - sets created_by_user_id
  - `update_exercise/3` - validates user owns exercise
  - `delete_exercise/2` - validates user owns exercise

#### ✅ 5. Update ExerciseController to get current user and pass to context functions
- Get current user using `Guardian.Plug.current_resource(conn)`
- Pass user to all context functions
- Follow existing controller patterns with `with` statements
- Use action_fallback for error handling

#### ✅ 6. Add routes for exercises in router.ex with authentication
- Add `resources "/exercises", ExerciseController, except: [:new, :edit]` in authenticated scope
- Routes protected by `:auth` pipeline

#### ✅ 7. Update ExerciseExecution schema to reference exercises table instead of integer
- Change `field :exercise, :integer` to `belongs_to :exercise, LogbookElix.Exercises.Exercise`
- Update changeset to validate exercise_id instead of exercise

#### ✅ 8. Create migration to update exercise_executions table to use exercise_id foreign key
- Add `exercise_id` foreign key referencing exercises table
- Add index on exercise_id
- delete old exercise column

### Medium Priority (Testing & Quality)

#### ✅ 9. Update test factory to include exercise factory
- Add exercise_factory with user relationship
- Add system_exercise_factory for system exercises
- Update exercise_execution_factory to use exercise relationship

#### ✅ 10. Create comprehensive tests for Exercise CRUD with authorization
- Context tests for authorization logic
- Controller tests with authentication
- Test user can only CRUD their own exercises
- Test listing returns both system and user exercises

### Low Priority (Data & Polish)

#### 🔄 11. Create seeds script to populate system exercises from CSV
- Parse CSV file with system exercises
- Create exercises with `is_system_created: true` and `created_by_user_id: nil`
- Run in seeds.exs

## Implementation Details

### Authorization Pattern
- Similar to workouts, where user context determines access
- System exercises: accessible by all users, not modifiable
- User exercises: only accessible and modifiable by creator

### Data Model
```elixir
# Exercise Schema
- name: string (required)
- body_part: enum (required)
- modality: enum (required)
- is_system_created: boolean (default: false)
- created_by_user_id: references users (nullable for system exercises)
```

### API Endpoints
- `GET /api/exercises` - List user's exercises + system exercises
- `POST /api/exercises` - Create new user exercise
- `GET /api/exercises/:id` - Get specific exercise (if authorized)
- `PUT /api/exercises/:id` - Update user's exercise
- `DELETE /api/exercises/:id` - Delete user's exercise

### Key Design Decisions
1. **Enum Implementation**: Use Ecto.Enum for type safety and validation
2. **Foreign Key Strategy**: Nullable created_by_user_id allows system exercises
3. **Query Optimization**: Proper indexes on commonly queried fields