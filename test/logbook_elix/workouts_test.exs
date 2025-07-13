defmodule LogbookElix.WorkoutsTest do
  use LogbookElix.DataCase

  import LogbookElix.Factory

  alias LogbookElix.Workouts

  describe "workouts" do
    alias LogbookElix.Workouts.Workout

    @invalid_attrs %{"finished_at" => "invalid-date"}

    test "list_workouts/1 returns workouts for the user" do
      user = insert(:user)
      other_user = insert(:user)
      user_workout = insert(:workout, user: user)
      _other_workout = insert(:workout, user: other_user)

      workouts = Workouts.list_workouts(user.id)

      assert length(workouts) == 1
      [found_workout] = workouts
      assert found_workout.id == user_workout.id
      assert found_workout.user_id == user.id
    end

    test "get_workout/2 returns the workout when user has access" do
      user = insert(:user)
      workout = insert(:workout, user: user)

      assert {:ok, found_workout} = Workouts.get_workout(workout.id, user.id)
      assert found_workout.id == workout.id
      assert found_workout.user_id == user.id
    end

    test "get_workout/2 returns error when user doesn't have access" do
      user = insert(:user)
      other_user = insert(:user)
      workout = insert(:workout, user: other_user)

      assert {:error, "Workout not found or access denied"} =
               Workouts.get_workout(workout.id, user.id)
    end

    test "get_workout/2 returns error when workout doesn't exist" do
      user = insert(:user)

      assert {:error, "Workout not found or access denied"} = Workouts.get_workout(999, user.id)
    end

    test "create_workout/2 with valid data creates a workout" do
      user = insert(:user)
      valid_attrs = %{"finished_at" => ~U[2025-07-07 12:00:00Z]}

      assert {:ok, %Workout{} = workout} = Workouts.create_workout(valid_attrs, user.id)
      assert workout.finished_at == valid_attrs["finished_at"]
      assert workout.user_id == user.id
    end

    test "create_workout/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Workouts.create_workout(@invalid_attrs, user.id)
    end

    test "update_workout/3 with valid data updates the workout when user has access" do
      user = insert(:user)
      workout = insert(:workout, user: user)
      update_attrs = %{"finished_at" => ~U[2025-07-07 05:50:00Z]}

      assert {:ok, %Workout{} = updated_workout} =
               Workouts.update_workout(workout.id, update_attrs, user.id)

      assert updated_workout.finished_at == ~U[2025-07-07 05:50:00Z]
    end

    test "update_workout/3 returns error when user doesn't have access" do
      user = insert(:user)
      other_user = insert(:user)
      workout = insert(:workout, user: other_user)
      update_attrs = %{"finished_at" => ~U[2025-07-07 05:50:00Z]}

      assert {:error, "Workout not found or access denied"} =
               Workouts.update_workout(workout.id, update_attrs, user.id)
    end

    test "update_workout/3 with invalid data returns error changeset" do
      user = insert(:user)
      workout = insert(:workout, user: user)

      assert {:error, %Ecto.Changeset{}} =
               Workouts.update_workout(workout.id, @invalid_attrs, user.id)
    end

    test "delete_workout/2 deletes the workout when user has access" do
      user = insert(:user)
      workout = insert(:workout, user: user)

      assert {:ok, %Workout{}} = Workouts.delete_workout(workout.id, user.id)

      assert {:error, "Workout not found or access denied"} =
               Workouts.get_workout(workout.id, user.id)
    end

    test "delete_workout/2 returns error when user doesn't have access" do
      user = insert(:user)
      other_user = insert(:user)
      workout = insert(:workout, user: other_user)

      assert {:error, "Workout not found or access denied"} =
               Workouts.delete_workout(workout.id, user.id)
    end

    test "change_workout/1 returns a workout changeset" do
      workout = insert(:workout)
      assert %Ecto.Changeset{} = Workouts.change_workout(workout)
    end
  end
end
