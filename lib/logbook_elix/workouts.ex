defmodule LogbookElix.Workouts do
  @moduledoc """
  The Workouts context.
  """

  import Ecto.Query, warn: false
  alias LogbookElix.Repo

  alias LogbookElix.Workouts.Workout

  @doc """
  Returns the list of workouts for a specific user.

  ## Examples

      iex> list_workouts(user_id)
      [%Workout{}, ...]

  """
  def list_workouts(user_id) do
    from(w in Workout,
      where: w.user_id == ^user_id,
      order_by: [desc: w.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single workout if the user has access to it.
  Returns the workout only if owned by the user.
  """
  def get_workout(id, user_id) do
    from(w in Workout,
      where: w.id == ^id,
      where: w.user_id == ^user_id
    )
    |> Repo.one()
    |> case do
      nil -> {:error, "Workout not found or access denied"}
      workout -> {:ok, workout}
    end
  end

  @doc """
  Gets a single workout if the user has access to it.

  Raises `Ecto.NoResultsError` if the Workout does not exist or user has no access.

  ## Examples

      iex> get_workout!(123, user_id)
      %Workout{}

      iex> get_workout!(456, user_id)
      ** (Ecto.NoResultsError)

  """
  def get_workout!(id, user_id) do
    case get_workout(id, user_id) do
      {:ok, workout} -> workout
      {:error, _reason} -> raise Ecto.NoResultsError, queryable: Workout
    end
  end

  @doc """
  Creates a workout for the given user.

  ## Examples

      iex> create_workout(%{field: value}, user_id)
      {:ok, %Workout{}}

      iex> create_workout(%{field: bad_value}, user_id)
      {:error, %Ecto.Changeset{}}

  """
  def create_workout(attrs, user_id) do
    attrs_with_user = Map.put(attrs, "user_id", user_id)

    %Workout{}
    |> Workout.changeset(attrs_with_user)
    |> Repo.insert()
  end

  @doc """
  Updates a workout if the user has access to it.

  ## Examples

      iex> update_workout(id, %{field: new_value}, user_id)
      {:ok, %Workout{}}

      iex> update_workout(id, %{field: bad_value}, user_id)
      {:error, %Ecto.Changeset{}}

  """
  def update_workout(id, attrs, user_id) do
    with {:ok, workout} <- get_workout(id, user_id) do
      workout
      |> Workout.changeset(attrs)
      |> Repo.update()
    end
  end

  @doc """
  Deletes a workout if the user has access to it.

  ## Examples

      iex> delete_workout(id, user_id)
      {:ok, %Workout{}}

      iex> delete_workout(id, user_id)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workout(id, user_id) do
    with {:ok, workout} <- get_workout(id, user_id) do
      Repo.delete(workout)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workout changes.

  ## Examples

      iex> change_workout(workout)
      %Ecto.Changeset{data: %Workout{}}

  """
  def change_workout(%Workout{} = workout, attrs \\ %{}) do
    Workout.changeset(workout, attrs)
  end
end
