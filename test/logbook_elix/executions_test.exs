defmodule LogbookElix.ExecutionsTest do
  use LogbookElix.DataCase

  import LogbookElix.Factory

  alias LogbookElix.Executions

  describe "exercise_executions" do
    alias LogbookElix.Executions.ExerciseExecution

    @invalid_attrs %{exercise: nil, note: nil, exercise_order: nil}

    test "list_exercise_executions/0 returns all exercise_executions" do
      exercise_execution = insert(:exercise_execution)
      [found_execution] = Executions.list_exercise_executions()
      assert found_execution.id == exercise_execution.id
      assert found_execution.exercise == exercise_execution.exercise
      assert found_execution.exercise_order == exercise_execution.exercise_order
      assert found_execution.workout_id == exercise_execution.workout_id
    end

    test "get_exercise_execution!/1 returns the exercise_execution with given id" do
      exercise_execution = insert(:exercise_execution)
      found_execution = Executions.get_exercise_execution!(exercise_execution.id)
      assert found_execution.id == exercise_execution.id
      assert found_execution.exercise == exercise_execution.exercise
      assert found_execution.exercise_order == exercise_execution.exercise_order
      assert found_execution.workout_id == exercise_execution.workout_id
    end

    test "create_exercise_execution/1 with valid data creates a exercise_execution" do
      workout = insert(:workout)
      valid_attrs = params_for(:exercise_execution) |> Map.put(:workout_id, workout.id)

      assert {:ok, %ExerciseExecution{} = exercise_execution} =
               Executions.create_exercise_execution(valid_attrs)

      assert exercise_execution.exercise == valid_attrs.exercise
      assert exercise_execution.note == valid_attrs.note
      assert exercise_execution.exercise_order == valid_attrs.exercise_order
      assert exercise_execution.workout_id == workout.id
    end

    test "create_exercise_execution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Executions.create_exercise_execution(@invalid_attrs)
    end

    test "update_exercise_execution/2 with valid data updates the exercise_execution" do
      exercise_execution = insert(:exercise_execution)
      update_attrs = %{exercise: 43, note: "some updated note", exercise_order: 43}

      assert {:ok, %ExerciseExecution{} = exercise_execution} =
               Executions.update_exercise_execution(exercise_execution, update_attrs)

      assert exercise_execution.exercise == 43
      assert exercise_execution.note == "some updated note"
      assert exercise_execution.exercise_order == 43
    end

    test "update_exercise_execution/2 with invalid data returns error changeset" do
      exercise_execution = insert(:exercise_execution)

      assert {:error, %Ecto.Changeset{}} =
               Executions.update_exercise_execution(exercise_execution, @invalid_attrs)

      found_execution = Executions.get_exercise_execution!(exercise_execution.id)
      assert found_execution.id == exercise_execution.id
      assert found_execution.exercise == exercise_execution.exercise
    end

    test "delete_exercise_execution/1 deletes the exercise_execution" do
      exercise_execution = insert(:exercise_execution)

      assert {:ok, %ExerciseExecution{}} =
               Executions.delete_exercise_execution(exercise_execution)

      assert_raise Ecto.NoResultsError, fn ->
        Executions.get_exercise_execution!(exercise_execution.id)
      end
    end

    test "change_exercise_execution/1 returns a exercise_execution changeset" do
      exercise_execution = insert(:exercise_execution)
      assert %Ecto.Changeset{} = Executions.change_exercise_execution(exercise_execution)
    end
  end
end
