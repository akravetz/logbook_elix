defmodule LogbookElix.Executions do
  @moduledoc """
  The Executions context.
  """

  import Ecto.Query, warn: false
  alias LogbookElix.Repo

  alias LogbookElix.Executions.ExerciseExecution
  alias LogbookElix.Sets.Set

  @doc """
  Returns the list of exercise_executions for the user.

  ## Examples

      iex> list_exercise_executions(user_id)
      [%ExerciseExecution{}, ...]

  """
  def list_exercise_executions(user_id) do
    from(ee in ExerciseExecution,
      join: w in assoc(ee, :workout),
      where: w.user_id == ^user_id,
      preload: [:exercise, :workout]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single exercise_execution if the user has access to it.

  ## Examples

      iex> get_exercise_execution(123, user_id)
      {:ok, %ExerciseExecution{}}

      iex> get_exercise_execution(456, user_id)
      {:error, "Exercise execution not found or access denied"}

  """
  def get_exercise_execution(id, user_id) do
    from(ee in ExerciseExecution,
      join: w in assoc(ee, :workout),
      where: ee.id == ^id,
      where: w.user_id == ^user_id,
      preload: [:exercise, :workout, :sets]
    )
    |> Repo.one()
    |> case do
      nil -> {:error, "Exercise execution not found or access denied"}
      exercise_execution -> {:ok, exercise_execution}
    end
  end

  @doc """
  Gets a single exercise_execution if the user has access to it.

  Raises `Ecto.NoResultsError` if the Exercise execution does not exist or user doesn't have access.

  ## Examples

      iex> get_exercise_execution!(123, user_id)
      %ExerciseExecution{}

      iex> get_exercise_execution!(456, user_id)
      ** (Ecto.NoResultsError)

  """
  def get_exercise_execution!(id, user_id) do
    case get_exercise_execution(id, user_id) do
      {:ok, exercise_execution} -> exercise_execution
      {:error, _reason} -> raise Ecto.NoResultsError, queryable: ExerciseExecution
    end
  end

  @doc """
  Creates a exercise_execution for the user's workout.

  ## Examples

      iex> create_exercise_execution(%{field: value}, user_id)
      {:ok, %ExerciseExecution{}}

      iex> create_exercise_execution(%{field: bad_value}, user_id)
      {:error, %Ecto.Changeset{}}

  """
  def create_exercise_execution(attrs, user_id) do
    with {:ok, workout_id} <- fetch_workout_id(attrs),
         {:ok, _workout} <- LogbookElix.Workouts.get_workout(workout_id, user_id),
         {:ok, exercise_execution} <- insert_exercise_execution(attrs) do
      {:ok, preload_exercise_execution(exercise_execution)}
    end
  end

  @doc """
  Updates a exercise_execution if the user has access to it.

  ## Examples

      iex> update_exercise_execution(id, %{field: new_value}, user_id)
      {:ok, %ExerciseExecution{}}

      iex> update_exercise_execution(id, %{field: bad_value}, user_id)
      {:error, %Ecto.Changeset{}}

  """
  def update_exercise_execution(id, attrs, user_id) do
    with {:ok, exercise_execution} <- get_exercise_execution(id, user_id),
         {:ok, updated_execution} <- update_exercise_execution_record(exercise_execution, attrs) do
      {:ok, preload_exercise_execution(updated_execution)}
    end
  end

  @doc """
  Deletes a exercise_execution if the user has access to it.

  ## Examples

      iex> delete_exercise_execution(id, user_id)
      {:ok, %ExerciseExecution{}}

      iex> delete_exercise_execution(id, user_id)
      {:error, %Ecto.Changeset{}}

  """
  def delete_exercise_execution(id, user_id) do
    with {:ok, exercise_execution} <- get_exercise_execution(id, user_id) do
      exercise_execution
      |> Repo.preload(:sets)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.cast_assoc(:sets, with: &Set.changeset/2)
      |> Repo.delete()
    end
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

  # Private helper functions

  defp preload_exercise_execution(exercise_execution) do
    Repo.preload(exercise_execution, [:exercise, :workout, :sets])
  end

  defp fetch_workout_id(attrs) do
    case Map.fetch(attrs, "workout_id") do
      :error -> {:error, "Exercise execution not found or access denied"}
      {:ok, workout_id} -> {:ok, workout_id}
    end
  end

  defp insert_exercise_execution(attrs) do
    %ExerciseExecution{}
    |> ExerciseExecution.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:sets, with: &Set.changeset/2)
    |> Repo.insert()
  end

  defp update_exercise_execution_record(exercise_execution, attrs) do
    exercise_execution
    |> Repo.preload(:sets)
    |> ExerciseExecution.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:sets, with: &Set.changeset/2)
    |> Repo.update()
  end
end
