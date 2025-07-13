defmodule LogbookElixWeb.ExerciseJSON do
  alias LogbookElix.Exercises.Exercise

  @doc """
  Renders a list of exercises.
  """
  def index(%{exercises: exercises}) do
    %{data: for(exercise <- exercises, do: data(exercise))}
  end

  @doc """
  Renders a single exercise.
  """
  def show(%{exercise: exercise}) do
    %{data: data(exercise)}
  end

  defp data(%Exercise{} = exercise) do
    %{
      id: exercise.id,
      name: exercise.name,
      body_part: exercise.body_part,
      modality: exercise.modality,
      is_system_created: exercise.is_system_created
    }
  end
end
