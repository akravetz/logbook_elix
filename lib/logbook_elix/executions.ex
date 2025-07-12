defmodule LogbookElix.Executions do
  @moduledoc """
  The Executions context.
  """

  import Ecto.Query, warn: false
  alias LogbookElix.Repo

  alias LogbookElix.Executions.ExerciseExecution
  alias LogbookElix.Sets.Set

  @doc """
  Returns the list of exercise_executions.

  ## Examples

      iex> list_exercise_executions()
      [%ExerciseExecution{}, ...]

  """
  def list_exercise_executions do
    from(ee in ExerciseExecution,
      preload: [:exercise]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single exercise_execution.

  Raises `Ecto.NoResultsError` if the Exercise execution does not exist.

  ## Examples

      iex> get_exercise_execution!(123)
      %ExerciseExecution{}

      iex> get_exercise_execution!(456)
      ** (Ecto.NoResultsError)

  """
  def get_exercise_execution!(id) do
    ExerciseExecution
    |> Repo.get!(id)
    |> Repo.preload([:exercise, :sets])
  end

  @doc """
  Creates a exercise_execution.

  ## Examples

      iex> create_exercise_execution(%{field: value})
      {:ok, %ExerciseExecution{}}

      iex> create_exercise_execution(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_exercise_execution(attrs \\ %{}) do
    %ExerciseExecution{}
    |> ExerciseExecution.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:sets, with: &Set.changeset/2)
    |> Repo.insert()
    |> case do
      {:ok, exercise_execution} -> {:ok, Repo.preload(exercise_execution, [:exercise, :sets])}
      error -> error
    end
  end

  @doc """
  Updates a exercise_execution.

  ## Examples

      iex> update_exercise_execution(exercise_execution, %{field: new_value})
      {:ok, %ExerciseExecution{}}

      iex> update_exercise_execution(exercise_execution, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_exercise_execution(%ExerciseExecution{} = exercise_execution, attrs) do
    exercise_execution
    |> Repo.preload(:sets)
    |> ExerciseExecution.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:sets, with: &Set.changeset/2)
    |> Repo.update()
    |> case do
      {:ok, exercise_execution} -> {:ok, Repo.preload(exercise_execution, [:exercise, :sets])}
      error -> error
    end
  end

  @doc """
  Deletes a exercise_execution.

  ## Examples

      iex> delete_exercise_execution(exercise_execution)
      {:ok, %ExerciseExecution{}}

      iex> delete_exercise_execution(exercise_execution)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exercise_execution(%ExerciseExecution{} = exercise_execution) do
    exercise_execution
    |> Repo.preload(:sets)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.cast_assoc(:sets, with: &Set.changeset/2)
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exercise_execution changes.

  ## Examples

      iex> change_exercise_execution(exercise_execution)
      %Ecto.Changeset{data: %ExerciseExecution{}}

  """
  def change_exercise_execution(%ExerciseExecution{} = exercise_execution, attrs \\ %{}) do
    ExerciseExecution.changeset(exercise_execution, attrs)
  end
end
