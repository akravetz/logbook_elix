defmodule LogbookElix.ExecutionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LogbookElix.Executions` context.
  """

  @doc """
  Generate a exercise_execution.
  """
  def exercise_execution_fixture(attrs \\ %{}) do
    {:ok, exercise_execution} =
      attrs
      |> Enum.into(%{
        exercise: 42,
        exercise_order: 42,
        note: "some note"
      })
      |> LogbookElix.Executions.create_exercise_execution()

    exercise_execution
  end
end
