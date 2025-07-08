defmodule LogbookElix.WorkoutsTest do
  use LogbookElix.DataCase

  import LogbookElix.Factory

  alias LogbookElix.Workouts

  describe "workouts" do
    alias LogbookElix.Workouts.Workout

    @invalid_attrs %{user_id: nil}

    test "list_workouts/0 returns all workouts" do
      workout = insert(:workout)
      [found_workout] = Workouts.list_workouts()
      assert found_workout.id == workout.id
      assert found_workout.finished_at == workout.finished_at
      assert found_workout.user_id == workout.user_id
    end

    test "get_workout!/1 returns the workout with given id" do
      workout = insert(:workout)
      found_workout = Workouts.get_workout!(workout.id)
      assert found_workout.id == workout.id
      assert found_workout.finished_at == workout.finished_at
      assert found_workout.user_id == workout.user_id
    end

    test "create_workout/1 with valid data creates a workout" do
      user = insert(:user)
      valid_attrs = params_for(:workout) |> Map.put(:user_id, user.id)

      assert {:ok, %Workout{} = workout} = Workouts.create_workout(valid_attrs)
      assert workout.finished_at == valid_attrs.finished_at
      assert workout.user_id == user.id
    end

    test "create_workout/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workouts.create_workout(@invalid_attrs)
    end

    test "update_workout/2 with valid data updates the workout" do
      workout = insert(:workout)
      update_attrs = %{finished_at: ~U[2025-07-07 05:50:00Z]}

      assert {:ok, %Workout{} = workout} = Workouts.update_workout(workout, update_attrs)
      assert workout.finished_at == ~U[2025-07-07 05:50:00Z]
    end

    test "update_workout/2 with invalid data returns error changeset" do
      workout = insert(:workout)
      assert {:error, %Ecto.Changeset{}} = Workouts.update_workout(workout, @invalid_attrs)
      found_workout = Workouts.get_workout!(workout.id)
      assert found_workout.id == workout.id
      assert found_workout.finished_at == workout.finished_at
    end

    test "delete_workout/1 deletes the workout" do
      workout = insert(:workout)
      assert {:ok, %Workout{}} = Workouts.delete_workout(workout)
      assert_raise Ecto.NoResultsError, fn -> Workouts.get_workout!(workout.id) end
    end

    test "change_workout/1 returns a workout changeset" do
      workout = insert(:workout)
      assert %Ecto.Changeset{} = Workouts.change_workout(workout)
    end
  end
end
