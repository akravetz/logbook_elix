# Elixir Anti-Patterns Guide

This document synthesizes key anti-patterns from the official Elixir documentation, providing examples and alternatives specific to Phoenix applications and our codebase patterns.

## Process Anti-Patterns

### 1. Code Organization by Process

**Problem**: Using processes for code organization instead of runtime properties.

#### ❌ Anti-Pattern
```elixir
# Don't use GenServer for pure calculations
defmodule Calculator do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add(a, b) do
    GenServer.call(__MODULE__, {:add, a, b})
  end

  def handle_call({:add, a, b}, _from, state) do
    {:reply, a + b, state}
  end
end
```

#### ✅ Refactored
```elixir
# Use modules and functions for stateless operations
defmodule Calculator do
  def add(a, b), do: a + b
  def subtract(a, b), do: a - b
end
```

### 2. Scattered Process Interfaces

**Problem**: Multiple modules directly interacting with the same process without coordination.

#### ❌ Anti-Pattern
```elixir
# Multiple modules accessing Agent directly
defmodule UserCache do
  def start_link, do: Agent.start_link(fn -> %{} end, name: __MODULE__)
end

# In different modules
defmodule UserController do
  def show(conn, %{"id" => id}) do
    Agent.update(UserCache, fn cache -> Map.put(cache, id, %{accessed: true}) end)
  end
end

defmodule UserStats do
  def track_login(user_id) do
    Agent.update(UserCache, fn cache -> Map.put(cache, user_id, DateTime.utc_now()) end)
  end
end
```

#### ✅ Refactored
```elixir
# Centralized interface
defmodule UserCache do
  def start_link, do: Agent.start_link(fn -> %{} end, name: __MODULE__)
  
  def mark_accessed(user_id) do
    Agent.update(__MODULE__, fn cache -> 
      Map.put(cache, user_id, %{accessed_at: DateTime.utc_now()})
    end)
  end
  
  def track_login(user_id) do
    Agent.update(__MODULE__, fn cache ->
      Map.update(cache, user_id, %{login_at: DateTime.utc_now()}, fn user ->
        Map.put(user, :login_at, DateTime.utc_now())
      end)
    end)
  end
end
```

### 3. Sending Unnecessary Data

**Problem**: Copying large amounts of data when sending messages between processes.

#### ❌ Anti-Pattern
```elixir
# Sending entire workout struct when only ID is needed
def notify_workout_completed(workout) do
  GenServer.cast(NotificationServer, {:workout_completed, workout})
end
```

#### ✅ Refactored
```elixir
# Send only necessary data
def notify_workout_completed(workout_id, user_id) do
  GenServer.cast(NotificationServer, {:workout_completed, workout_id, user_id})
end

# Or let the receiving process fetch data
def notify_workout_completed(workout_id) do
  GenServer.cast(NotificationServer, {:workout_completed, workout_id})
end

# In the GenServer
def handle_cast({:workout_completed, workout_id}, state) do
  workout = Workouts.get_workout!(workout_id)
  # Process notification...
  {:noreply, state}
end
```

### 4. Unsupervised Processes

**Problem**: Creating long-running processes outside supervision trees.

#### ❌ Anti-Pattern
```elixir
# Starting processes without supervision
def start_background_tasks do
  spawn(fn -> process_workout_analytics() end)
  spawn(fn -> cleanup_expired_sessions() end)
end
```

#### ✅ Refactored
```elixir
# Add to supervision tree in application.ex
def start(_type, _args) do
  children = [
    LogbookElix.Repo,
    LogbookElixWeb.Endpoint,
    {WorkoutAnalytics, []},
    {SessionCleanup, []}
  ]
  
  Supervisor.start_link(children, strategy: :one_for_one, name: LogbookElix.Supervisor)
end
```

## Design Anti-Patterns

### 1. Alternative Return Types

**Problem**: Functions with options that drastically change their return type.

#### ❌ Anti-Pattern
```elixir
def get_user(id, opts \\ []) do
  user = Repo.get(User, id)
  
  if Keyword.get(opts, :with_workouts, false) do
    Repo.preload(user, :workouts)
  else
    user
  end
end
```

#### ✅ Refactored
```elixir
def get_user(id), do: Repo.get(User, id)
def get_user_with_workouts(id), do: Repo.get(User, id) |> Repo.preload(:workouts)
```

### 2. Boolean Obsession

**Problem**: Overusing booleans to encode complex state information.

#### ❌ Anti-Pattern
```elixir
defmodule User do
  schema "users" do
    field :is_admin, :boolean
    field :is_moderator, :boolean
    field :is_premium, :boolean
    field :is_active, :boolean
  end
end
```

#### ✅ Refactored
```elixir
defmodule User do
  schema "users" do
    field :role, Ecto.Enum, values: [:user, :moderator, :admin]
    field :subscription_type, Ecto.Enum, values: [:free, :premium]
    field :status, Ecto.Enum, values: [:active, :suspended, :deleted]
  end
end
```

### 3. Exceptions for Control Flow

**Problem**: Using exceptions to manage program logic instead of pattern matching.

#### ❌ Anti-Pattern
```elixir
def create_workout(attrs) do
  try do
    workout = %Workout{}
    |> Workout.changeset(attrs)
    |> Repo.insert!()
    
    {:ok, workout}
  rescue
    e in Ecto.InvalidChangesetError ->
      {:error, e.changeset}
  end
end
```

#### ✅ Refactored (Already Following in Our Codebase)
```elixir
def create_workout(attrs) do
  %Workout{}
  |> Workout.changeset(attrs)
  |> Repo.insert()
end
```

### 4. Primitive Obsession

**Problem**: Overusing basic types to represent complex data.

#### ❌ Anti-Pattern
```elixir
# Using strings for complex data
def create_exercise(name, body_part, equipment, difficulty) do
  # body_part, equipment, difficulty as strings
end
```

#### ✅ Refactored (Already Following in Our Codebase)
```elixir
defmodule Exercise do
  schema "exercises" do
    field :name, :string
    field :body_part, Ecto.Enum, values: [:chest, :back, :shoulders, :arms, :legs, :core]
    field :modality, Ecto.Enum, values: [:barbell, :dumbbell, :cable, :machine, :bodyweight]
  end
end
```

### 5. Unrelated Multi-Clause Functions

**Problem**: Combining unrelated functionality in a single multi-clause function.

#### ❌ Anti-Pattern
```elixir
def update(%User{} = user, attrs), do: User.changeset(user, attrs) |> Repo.update()
def update(%Workout{} = workout, attrs), do: Workout.changeset(workout, attrs) |> Repo.update()
def update(%Exercise{} = exercise, attrs), do: Exercise.changeset(exercise, attrs) |> Repo.update()
```

#### ✅ Refactored
```elixir
# Separate functions in appropriate contexts
defmodule Accounts do
  def update_user(user, attrs), do: User.changeset(user, attrs) |> Repo.update()
end

defmodule Workouts do
  def update_workout(workout, attrs), do: Workout.changeset(workout, attrs) |> Repo.update()
end

defmodule Exercises do
  def update_exercise(exercise, attrs), do: Exercise.changeset(exercise, attrs) |> Repo.update()
end
```

### 6. Using Application Configuration for Libraries

**Problem**: Configuring library behavior through global application environment.

#### ❌ Anti-Pattern
```elixir
# In config.exs
config :my_app, :api_client, base_url: "https://api.example.com"

# In code
def make_request(path) do
  base_url = Application.get_env(:my_app, :api_client)[:base_url]
  HTTPoison.get("#{base_url}#{path}")
end
```

#### ✅ Refactored
```elixir
def make_request(path, base_url \\ "https://api.example.com") do
  HTTPoison.get("#{base_url}#{path}")
end

# Or for our DeepGram client
defmodule DeepgramClient do
  def transcribe(audio_data, api_key) do
    # Pass configuration as parameter
  end
end
```

## Code Anti-Patterns

### 1. Comments Overuse

**Problem**: Excessive comments make code less readable.

#### ❌ Anti-Pattern
```elixir
def create_workout(attrs, user_id) do
  # Create a new workout with the given attributes and user ID
  with {:ok, workout} <- Workouts.create_workout(attrs, user_id) do
    # Return the created workout
    {:ok, workout}
  end
end
```

#### ✅ Refactored
```elixir
def create_workout(attrs, user_id) do
  Workouts.create_workout(attrs, user_id)
end
```

### 2. Complex `else` Clauses in `with`

**Problem**: Flattening error clauses into a single complex `else` block.

#### ❌ Anti-Pattern
```elixir
def verify_google_token(google_token) do
  with {:ok, user_info} <- GoogleTokenVerifier.verify_token(google_token),
       {:ok, user} <- Accounts.find_or_create_user_by_email(user_info),
       {:ok, jwt, _claims} <- Guardian.encode_and_sign(user) do
    {:ok, jwt, user}
  else
    {:error, :invalid_token} -> {:error, "Invalid Google token"}
    {:error, :network_error} -> {:error, "Network error"}
    {:error, %Ecto.Changeset{}} -> {:error, "User creation failed"}
    {:error, reason} when is_binary(reason) -> {:error, reason}
    error -> {:error, "Authentication failed"}
  end
end
```

#### ✅ Refactored (Already Following in Our Codebase)
```elixir
def verify_google_token(google_token) do
  with {:ok, user_info} <- GoogleTokenVerifier.verify_token(google_token),
       {:ok, user} <- Accounts.find_or_create_user_by_email(user_info),
       {:ok, jwt, _claims} <- Guardian.encode_and_sign(user) do
    {:ok, jwt, user}
  end
  # Let FallbackController handle errors
end
```

### 3. Dynamic Atom Creation

**Problem**: Creating atoms dynamically without control, risking memory issues.

#### ❌ Anti-Pattern
```elixir
def get_exercise_by_body_part(body_part_string) do
  body_part = String.to_atom(body_part_string)  # Dangerous!
  from(e in Exercise, where: e.body_part == ^body_part)
end
```

#### ✅ Refactored
```elixir
@valid_body_parts ~w(chest back shoulders arms legs core)a

def get_exercise_by_body_part(body_part_string) when body_part_string in @valid_body_parts do
  body_part = String.to_existing_atom(body_part_string)
  from(e in Exercise, where: e.body_part == ^body_part)
end

# Or use Ecto.Enum validation
def get_exercise_by_body_part(body_part) when body_part in [:chest, :back, :shoulders, :arms, :legs, :core] do
  from(e in Exercise, where: e.body_part == ^body_part)
end
```

### 4. Long Parameter List

**Problem**: Functions with too many arguments becoming confusing.

#### ❌ Anti-Pattern
```elixir
def create_exercise_execution(workout_id, exercise_id, note, exercise_order, reps, weight, forced_reps) do
  # Too many parameters
end
```

#### ✅ Refactored
```elixir
def create_exercise_execution(workout_id, exercise_execution_params) do
  # Group related parameters into a map/struct
  params = Map.put(exercise_execution_params, :workout_id, workout_id)
  # Process params...
end
```

### 5. Non-Assertive Map Access

**Problem**: Using dynamic map access for keys that should always exist.

#### ❌ Anti-Pattern
```elixir
def process_workout_params(params) do
  name = params["name"]           # Might be nil
  user_id = params["user_id"]     # Should always exist
  # Process...
end
```

#### ✅ Refactored
```elixir
def process_workout_params(%{"user_id" => user_id} = params) do
  name = params["name"]  # OK to be nil
  # user_id is guaranteed to exist via pattern matching
end
```

### 6. Non-Assertive Pattern Matching

**Problem**: Writing defensive code that returns incorrect values instead of failing.

#### ❌ Anti-Pattern
```elixir
def extract_user_id(%{user: user}) when is_map(user) do
  Map.get(user, :id, nil)  # Returns nil instead of failing
end
def extract_user_id(_), do: nil
```

#### ✅ Refactored
```elixir
def extract_user_id(%{user: %{id: id}}), do: id
# Let it crash if structure is wrong - this reveals bugs
```

## Phoenix-Specific Anti-Patterns

### 1. Manual Error Handling in Controllers

**Problem**: Manually handling every error case instead of using FallbackController.

#### ❌ Anti-Pattern
```elixir
def create(conn, %{"workout" => workout_params}) do
  case Workouts.create_workout(workout_params) do
    {:ok, workout} ->
      conn
      |> put_status(:created)
      |> render(:show, workout: workout)
    {:error, changeset} ->
      conn
      |> put_status(:unprocessable_entity)
      |> render(:error, changeset: changeset)
  end
end
```

#### ✅ Refactored (Already Following in Our Codebase)
```elixir
def create(conn, %{"workout" => workout_params}) do
  user = Guardian.Plug.current_resource(conn)

  with {:ok, workout} <- Workouts.create_workout(workout_params, user.id) do
    conn
    |> put_status(:created)
    |> render(:show, workout: workout)
  end
end
# FallbackController handles errors
```

### 2. Direct Database Access in Controllers

**Problem**: Controllers directly interacting with Repo instead of using contexts.

#### ❌ Anti-Pattern
```elixir
def show(conn, %{"id" => id}) do
  workout = Repo.get!(Workout, id)
  render(conn, :show, workout: workout)
end
```

#### ✅ Refactored (Already Following in Our Codebase)
```elixir
def show(conn, %{"id" => id}) do
  user = Guardian.Plug.current_resource(conn)
  
  with {:ok, workout} <- Workouts.get_workout(id, user.id) do
    render(conn, :show, workout: workout)
  end
end
```

## Summary

These anti-patterns emphasize key Elixir principles:

1. **Clarity over Cleverness**: Write explicit, readable code
2. **Let It Crash**: Don't defensively handle every edge case
3. **Separation of Concerns**: Keep processes, modules, and functions focused
4. **Pattern Matching**: Use Elixir's strengths instead of defensive programming
5. **Contexts over Direct Access**: Maintain clean boundaries in Phoenix applications

Our codebase already follows many of these patterns well, particularly around error handling with `with` statements and FallbackController, proper use of contexts, and clear module organization. Continue applying these principles as the application grows.