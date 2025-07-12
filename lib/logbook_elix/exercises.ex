defmodule LogbookElix.Exercises do
  @moduledoc """
  The Exercises context.
  """

  import Ecto.Query, warn: false
  alias LogbookElix.Repo

  alias LogbookElix.Exercises.Exercise

  @doc """
  Returns the list of exercises accessible to the user.
  Includes system exercises and user's own exercises.
  """
  def list_exercises(user_id) do
    from(e in Exercise,
      where: e.is_system_created == true or e.created_by_user_id == ^user_id,
      order_by: [asc: e.name]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single exercise if the user has access to it.
  Returns the exercise if it's a system exercise or owned by the user.
  """
  def get_exercise(id, user_id) do
    from(e in Exercise,
      where: e.id == ^id,
      where: e.is_system_created == true or e.created_by_user_id == ^user_id
    )
    |> Repo.one()
    |> case do
      nil -> {:error, "Exercise not found or access denied"}
      exercise -> {:ok, exercise}
    end
  end

  @doc """
  Gets a single exercise if the user has access to it.
  Raises `Ecto.NoResultsError` if the Exercise does not exist or user has no access.
  """
  def get_exercise!(id, user_id) do
    case get_exercise(id, user_id) do
      {:ok, exercise} -> exercise
      {:error, _reason} -> raise Ecto.NoResultsError, queryable: Exercise
    end
  end

  @doc """
  Creates an exercise for the given user.
  """
  def create_exercise(attrs, user_id) do
    attrs_with_user =
      attrs
      |> Map.put("created_by_user_id", user_id)
      |> Map.put("is_system_created", false)

    %Exercise{}
    |> Exercise.changeset(attrs_with_user)
    |> Repo.insert()
  end

  @doc """
  Updates an exercise if the user owns it.
  System exercises cannot be updated.
  """
  def update_exercise(id, attrs, user_id) do
    with {:ok, exercise} <- get_exercise(id, user_id),
         false <- exercise.is_system_created do
      exercise
      |> Exercise.changeset(attrs)
      |> Repo.update()
    else
      true -> {:error, "Cannot modify system exercises"}
      error -> error
    end
  end

  @doc """
  Deletes an exercise if the user owns it.
  System exercises cannot be deleted.
  """
  def delete_exercise(id, user_id) do
    with {:ok, exercise} <- get_exercise(id, user_id),
         false <- exercise.is_system_created do
      Repo.delete(exercise)
    else
      true -> {:error, "Cannot delete system exercises"}
      error -> error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exercise changes.
  """
  def change_exercise(%Exercise{} = exercise, attrs \\ %{}) do
    Exercise.changeset(exercise, attrs)
  end
end
