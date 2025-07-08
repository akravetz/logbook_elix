defmodule LogbookElix.Factory do
  @moduledoc """
  Factory for creating test data using ExMachina.
  Handles entity relationships automatically.
  """

  use ExMachina.Ecto, repo: LogbookElix.Repo

  alias LogbookElix.Accounts.User
  alias LogbookElix.Workouts.Workout
  alias LogbookElix.Executions.ExerciseExecution
  alias LogbookElix.Sets.Set

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
      user: build(:user),
      finished_at: ~U[2025-07-07 12:00:00Z]
    }
  end

  def exercise_execution_factory do
    %ExerciseExecution{
      workout: build(:workout),
      exercise: sequence(:exercise, &(&1 + 1)),
      exercise_order: sequence(:exercise_order, &(&1 + 1)),
      note: "Exercise note"
    }
  end

  def set_factory do
    %Set{
      exercise_execution: build(:exercise_execution),
      clean_reps: 10,
      weight: 135.0,
      forced_reps: 0
    }
  end
end
