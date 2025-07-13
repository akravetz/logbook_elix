defmodule LogbookElixWeb.ExerciseExecutionJSON do
  alias LogbookElix.Executions.ExerciseExecution

  @doc """
  Renders a list of exercise_executions.
  """
  def index(%{exercise_executions: exercise_executions}) do
    %{data: for(exercise_execution <- exercise_executions, do: data(exercise_execution))}
  end

  @doc """
  Renders a single exercise_execution.
  """
  def show(%{exercise_execution: exercise_execution}) do
    %{data: data(exercise_execution)}
  end

  defp data(%ExerciseExecution{} = exercise_execution) do
    %{
      id: exercise_execution.id,
      exercise: exercise_execution.exercise,
      note: exercise_execution.note,
      exercise_order: exercise_execution.exercise_order,
      sets: exercise_execution.sets
    }
  end
end
