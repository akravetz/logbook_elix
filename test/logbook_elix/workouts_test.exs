defmodule LogbookElix.WorkoutsTest do
  use LogbookElix.DataCase

  alias LogbookElix.Workouts

  describe "workouts" do
    alias LogbookElix.Workouts.Workout

    import LogbookElix.WorkoutsFixtures

    @invalid_attrs %{finished_at: nil}

    test "list_workouts/0 returns all workouts" do
      workout = workout_fixture()
      assert Workouts.list_workouts() == [workout]
    end

    test "get_workout!/1 returns the workout with given id" do
      workout = workout_fixture()
      assert Workouts.get_workout!(workout.id) == workout
    end

    test "create_workout/1 with valid data creates a workout" do
      valid_attrs = %{finished_at: ~U[2025-07-06 05:50:00Z]}

      assert {:ok, %Workout{} = workout} = Workouts.create_workout(valid_attrs)
      assert workout.finished_at == ~U[2025-07-06 05:50:00Z]
    end

    test "create_workout/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workouts.create_workout(@invalid_attrs)
    end

    test "update_workout/2 with valid data updates the workout" do
      workout = workout_fixture()
      update_attrs = %{finished_at: ~U[2025-07-07 05:50:00Z]}

      assert {:ok, %Workout{} = workout} = Workouts.update_workout(workout, update_attrs)
      assert workout.finished_at == ~U[2025-07-07 05:50:00Z]
    end

    test "update_workout/2 with invalid data returns error changeset" do
      workout = workout_fixture()
      assert {:error, %Ecto.Changeset{}} = Workouts.update_workout(workout, @invalid_attrs)
      assert workout == Workouts.get_workout!(workout.id)
    end

    test "delete_workout/1 deletes the workout" do
      workout = workout_fixture()
      assert {:ok, %Workout{}} = Workouts.delete_workout(workout)
      assert_raise Ecto.NoResultsError, fn -> Workouts.get_workout!(workout.id) end
    end

    test "change_workout/1 returns a workout changeset" do
      workout = workout_fixture()
      assert %Ecto.Changeset{} = Workouts.change_workout(workout)
    end
  end
end
