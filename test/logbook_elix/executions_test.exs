defmodule LogbookElix.ExecutionsTest do
  use LogbookElix.DataCase

  alias LogbookElix.Executions

  describe "exercise_executions" do
    alias LogbookElix.Executions.ExerciseExecution

    import LogbookElix.ExecutionsFixtures

    @invalid_attrs %{exercise: nil, note: nil, exercise_order: nil}

    test "list_exercise_executions/0 returns all exercise_executions" do
      exercise_execution = exercise_execution_fixture()
      assert Executions.list_exercise_executions() == [exercise_execution]
    end

    test "get_exercise_execution!/1 returns the exercise_execution with given id" do
      exercise_execution = exercise_execution_fixture()
      assert Executions.get_exercise_execution!(exercise_execution.id) == exercise_execution
    end

    test "create_exercise_execution/1 with valid data creates a exercise_execution" do
      valid_attrs = %{exercise: 42, note: "some note", exercise_order: 42}

      assert {:ok, %ExerciseExecution{} = exercise_execution} = Executions.create_exercise_execution(valid_attrs)
      assert exercise_execution.exercise == 42
      assert exercise_execution.note == "some note"
      assert exercise_execution.exercise_order == 42
    end

    test "create_exercise_execution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Executions.create_exercise_execution(@invalid_attrs)
    end

    test "update_exercise_execution/2 with valid data updates the exercise_execution" do
      exercise_execution = exercise_execution_fixture()
      update_attrs = %{exercise: 43, note: "some updated note", exercise_order: 43}

      assert {:ok, %ExerciseExecution{} = exercise_execution} = Executions.update_exercise_execution(exercise_execution, update_attrs)
      assert exercise_execution.exercise == 43
      assert exercise_execution.note == "some updated note"
      assert exercise_execution.exercise_order == 43
    end

    test "update_exercise_execution/2 with invalid data returns error changeset" do
      exercise_execution = exercise_execution_fixture()
      assert {:error, %Ecto.Changeset{}} = Executions.update_exercise_execution(exercise_execution, @invalid_attrs)
      assert exercise_execution == Executions.get_exercise_execution!(exercise_execution.id)
    end

    test "delete_exercise_execution/1 deletes the exercise_execution" do
      exercise_execution = exercise_execution_fixture()
      assert {:ok, %ExerciseExecution{}} = Executions.delete_exercise_execution(exercise_execution)
      assert_raise Ecto.NoResultsError, fn -> Executions.get_exercise_execution!(exercise_execution.id) end
    end

    test "change_exercise_execution/1 returns a exercise_execution changeset" do
      exercise_execution = exercise_execution_fixture()
      assert %Ecto.Changeset{} = Executions.change_exercise_execution(exercise_execution)
    end
  end
end
