defmodule LogbookElix.WorkoutsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LogbookElix.Workouts` context.
  """

  @doc """
  Generate a workout.
  """
  def workout_fixture(attrs \\ %{}) do
    {:ok, workout} =
      attrs
      |> Enum.into(%{
        finished_at: ~U[2025-07-06 05:50:00Z]
      })
      |> LogbookElix.Workouts.create_workout()

    workout
  end
end
