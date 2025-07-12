defmodule LogbookElix.ExercisesTest do
  use LogbookElix.DataCase

  import LogbookElix.Factory

  alias LogbookElix.Exercises
  alias LogbookElix.Exercises.Exercise

  describe "exercises" do
    @invalid_attrs %{"name" => nil, "body_part" => nil, "modality" => nil}

    test "list_exercises/1 returns system exercises and user's exercises" do
      user = insert(:user)
      other_user = insert(:user)

      system_exercise = insert(:system_exercise)
      user_exercise = insert(:exercise, created_by_user: user)
      _other_user_exercise = insert(:exercise, created_by_user: other_user)

      exercises = Exercises.list_exercises(user.id)

      assert length(exercises) == 2
      exercise_ids = Enum.map(exercises, & &1.id)
      assert system_exercise.id in exercise_ids
      assert user_exercise.id in exercise_ids
    end

    test "get_exercise/2 returns exercise if user has access" do
      user = insert(:user)
      exercise = insert(:exercise, created_by_user: user)

      assert {:ok, returned_exercise} = Exercises.get_exercise(exercise.id, user.id)
      assert returned_exercise.id == exercise.id
    end

    test "get_exercise/2 returns system exercise for any user" do
      user = insert(:user)
      system_exercise = insert(:system_exercise)

      assert {:ok, returned_exercise} = Exercises.get_exercise(system_exercise.id, user.id)
      assert returned_exercise.id == system_exercise.id
    end

    test "get_exercise/2 returns error if user cannot access exercise" do
      user = insert(:user)
      other_user = insert(:user)
      other_exercise = insert(:exercise, created_by_user: other_user)

      assert {:error, "Exercise not found or access denied"} =
               Exercises.get_exercise(other_exercise.id, user.id)
    end

    test "get_exercise!/2 returns the exercise with given id if user has access" do
      user = insert(:user)
      exercise = insert(:exercise, created_by_user: user)

      returned_exercise = Exercises.get_exercise!(exercise.id, user.id)
      assert returned_exercise.id == exercise.id
    end

    test "create_exercise/2 with valid data creates a exercise" do
      user = insert(:user)
      valid_attrs = %{"name" => "Test Exercise", "body_part" => "chest", "modality" => "barbell"}

      assert {:ok, %Exercise{} = exercise} = Exercises.create_exercise(valid_attrs, user.id)
      assert exercise.name == "Test Exercise"
      assert exercise.body_part == :chest
      assert exercise.modality == :barbell
      assert exercise.is_system_created == false
      assert exercise.created_by_user_id == user.id
    end

    test "create_exercise/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Exercises.create_exercise(@invalid_attrs, user.id)
    end

    test "update_exercise/3 with valid data updates the exercise" do
      user = insert(:user)
      exercise = insert(:exercise, created_by_user: user)

      update_attrs = %{
        "name" => "Updated Exercise",
        "body_part" => "back",
        "modality" => "dumbbell"
      }

      assert {:ok, %Exercise{} = updated_exercise} =
               Exercises.update_exercise(exercise.id, update_attrs, user.id)

      assert updated_exercise.name == "Updated Exercise"
      assert updated_exercise.body_part == :back
      assert updated_exercise.modality == :dumbbell
    end

    test "update_exercise/3 prevents updating system exercises" do
      user = insert(:user)
      system_exercise = insert(:system_exercise)
      update_attrs = %{"name" => "Hacked Exercise"}

      assert {:error, "Cannot modify system exercises"} =
               Exercises.update_exercise(system_exercise.id, update_attrs, user.id)
    end

    test "update_exercise/3 prevents updating other user's exercises" do
      user = insert(:user)
      other_user = insert(:user)
      other_exercise = insert(:exercise, created_by_user: other_user)
      update_attrs = %{"name" => "Hacked Exercise"}

      assert {:error, "Exercise not found or access denied"} =
               Exercises.update_exercise(other_exercise.id, update_attrs, user.id)
    end

    test "update_exercise/3 with invalid data returns error changeset" do
      user = insert(:user)
      exercise = insert(:exercise, created_by_user: user)

      assert {:error, %Ecto.Changeset{}} =
               Exercises.update_exercise(exercise.id, @invalid_attrs, user.id)
    end

    test "delete_exercise/2 deletes the exercise" do
      user = insert(:user)
      exercise = insert(:exercise, created_by_user: user)

      assert {:ok, %Exercise{}} = Exercises.delete_exercise(exercise.id, user.id)

      assert {:error, "Exercise not found or access denied"} =
               Exercises.get_exercise(exercise.id, user.id)
    end

    test "delete_exercise/2 prevents deleting system exercises" do
      user = insert(:user)
      system_exercise = insert(:system_exercise)

      assert {:error, "Cannot delete system exercises"} =
               Exercises.delete_exercise(system_exercise.id, user.id)
    end

    test "delete_exercise/2 prevents deleting other user's exercises" do
      user = insert(:user)
      other_user = insert(:user)
      other_exercise = insert(:exercise, created_by_user: other_user)

      assert {:error, "Exercise not found or access denied"} =
               Exercises.delete_exercise(other_exercise.id, user.id)
    end

    test "change_exercise/1 returns a exercise changeset" do
      exercise = insert(:exercise)
      assert %Ecto.Changeset{} = Exercises.change_exercise(exercise)
    end
  end
end
