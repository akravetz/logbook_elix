defmodule LogbookElix.ExecutionsTest do
  use LogbookElix.DataCase

  import LogbookElix.Factory

  alias LogbookElix.Executions

  describe "exercise_executions" do
    alias LogbookElix.Executions.ExerciseExecution

    @invalid_attrs %{exercise_id: nil, note: nil, exercise_order: nil}

    test "list_exercise_executions/1 returns exercise_executions for the user" do
      user = insert(:user)
      other_user = insert(:user)
      user_workout = insert(:workout, user: user)
      other_workout = insert(:workout, user: other_user)
      user_execution = insert(:exercise_execution, workout: user_workout)
      _other_execution = insert(:exercise_execution, workout: other_workout)

      executions = Executions.list_exercise_executions(user.id)

      assert length(executions) == 1
      [found_execution] = executions
      assert found_execution.id == user_execution.id
      assert found_execution.workout.user_id == user.id
    end

    test "get_exercise_execution/2 returns the exercise_execution when user has access" do
      user = insert(:user)
      workout = insert(:workout, user: user)
      exercise_execution = insert(:exercise_execution, workout: workout)

      assert {:ok, found_execution} =
               Executions.get_exercise_execution(exercise_execution.id, user.id)

      assert found_execution.id == exercise_execution.id
      assert found_execution.workout.user_id == user.id
    end

    test "get_exercise_execution/2 returns error when user doesn't have access" do
      user = insert(:user)
      other_user = insert(:user)
      other_workout = insert(:workout, user: other_user)
      exercise_execution = insert(:exercise_execution, workout: other_workout)

      assert {:error, "Exercise execution not found or access denied"} =
               Executions.get_exercise_execution(exercise_execution.id, user.id)
    end

    test "get_exercise_execution/2 returns error when execution doesn't exist" do
      user = insert(:user)

      assert {:error, "Exercise execution not found or access denied"} =
               Executions.get_exercise_execution(999, user.id)
    end

    test "create_exercise_execution/2 with valid data creates a exercise_execution" do
      user = insert(:user)
      workout = insert(:workout, user: user)
      exercise = insert(:exercise)

      valid_attrs = %{
        "exercise_id" => exercise.id,
        "workout_id" => workout.id,
        "exercise_order" => 1,
        "note" => "Test note"
      }

      assert {:ok, %ExerciseExecution{} = exercise_execution} =
               Executions.create_exercise_execution(valid_attrs, user.id)

      assert exercise_execution.exercise_id == valid_attrs["exercise_id"]
      assert exercise_execution.note == valid_attrs["note"]
      assert exercise_execution.exercise_order == valid_attrs["exercise_order"]
      assert exercise_execution.workout_id == workout.id
    end

    test "create_exercise_execution/2 returns error when user doesn't own workout" do
      user = insert(:user)
      other_user = insert(:user)
      other_workout = insert(:workout, user: other_user)
      exercise = insert(:exercise)

      valid_attrs = %{
        "exercise_id" => exercise.id,
        "workout_id" => other_workout.id,
        "exercise_order" => 1,
        "note" => "Test note"
      }

      assert {:error, "Workout not found or access denied"} =
               Executions.create_exercise_execution(valid_attrs, user.id)
    end

    test "create_exercise_execution/2 with invalid data returns error changeset" do
      user = insert(:user)

      assert {:error, "Exercise execution not found or access denied"} =
               Executions.create_exercise_execution(@invalid_attrs, user.id)
    end

    test "update_exercise_execution/3 with valid data updates the exercise_execution when user has access" do
      user = insert(:user)
      workout = insert(:workout, user: user)
      exercise_execution = insert(:exercise_execution, workout: workout)
      new_exercise = insert(:exercise)

      update_attrs = %{
        "exercise_id" => new_exercise.id,
        "note" => "some updated note",
        "exercise_order" => 43
      }

      assert {:ok, %ExerciseExecution{} = updated_execution} =
               Executions.update_exercise_execution(exercise_execution.id, update_attrs, user.id)

      assert updated_execution.exercise_id == new_exercise.id
      assert updated_execution.note == "some updated note"
      assert updated_execution.exercise_order == 43
    end

    test "update_exercise_execution/3 returns error when user doesn't have access" do
      user = insert(:user)
      other_user = insert(:user)
      other_workout = insert(:workout, user: other_user)
      exercise_execution = insert(:exercise_execution, workout: other_workout)

      update_attrs = %{
        "note" => "some updated note"
      }

      assert {:error, "Exercise execution not found or access denied"} =
               Executions.update_exercise_execution(exercise_execution.id, update_attrs, user.id)
    end

    test "update_exercise_execution/3 with invalid data returns error changeset" do
      user = insert(:user)
      workout = insert(:workout, user: user)
      exercise_execution = insert(:exercise_execution, workout: workout)

      assert {:error, %Ecto.Changeset{}} =
               Executions.update_exercise_execution(
                 exercise_execution.id,
                 @invalid_attrs,
                 user.id
               )
    end

    test "delete_exercise_execution/2 deletes the exercise_execution when user has access" do
      user = insert(:user)
      workout = insert(:workout, user: user)
      exercise_execution = insert(:exercise_execution, workout: workout)

      assert {:ok, %ExerciseExecution{}} =
               Executions.delete_exercise_execution(exercise_execution.id, user.id)

      assert {:error, "Exercise execution not found or access denied"} =
               Executions.get_exercise_execution(exercise_execution.id, user.id)
    end

    test "delete_exercise_execution/2 returns error when user doesn't have access" do
      user = insert(:user)
      other_user = insert(:user)
      other_workout = insert(:workout, user: other_user)
      exercise_execution = insert(:exercise_execution, workout: other_workout)

      assert {:error, "Exercise execution not found or access denied"} =
               Executions.delete_exercise_execution(exercise_execution.id, user.id)
    end

    test "change_exercise_execution/1 returns a exercise_execution changeset" do
      exercise_execution = insert(:exercise_execution)
      assert %Ecto.Changeset{} = Executions.change_exercise_execution(exercise_execution)
    end
  end
end
