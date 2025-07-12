defmodule LogbookElixWeb.ExerciseExecutionControllerTest do
  use LogbookElixWeb.ConnCase

  import LogbookElix.Factory
  import LogbookElixWeb.AuthTestHelper

  alias LogbookElix.Executions.ExerciseExecution

  # Will be merged with workout_id and exercise_id in tests
  @create_attrs %{
    note: "some note",
    exercise_order: 42
  }
  @update_attrs %{
    note: "some updated note",
    exercise_order: 43
  }
  @invalid_attrs %{exercise_id: nil, note: nil, exercise_order: nil}

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> authenticated_conn()

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all exercise_executions", %{conn: conn} do
      conn = get(conn, ~p"/api/exercise_executions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create exercise_execution" do
    test "renders exercise_execution when data is valid", %{conn: conn} do
      workout = insert(:workout)
      exercise = insert(:exercise)

      attrs =
        @create_attrs
        |> Map.put(:workout_id, workout.id)
        |> Map.put(:exercise_id, exercise.id)

      conn = post(conn, ~p"/api/exercise_executions", exercise_execution: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/exercise_executions/#{id}")

      assert %{
               "id" => ^id,
               "exercise" => %{"id" => exercise_id},
               "exercise_order" => 42,
               "note" => "some note"
             } = json_response(conn, 200)["data"]

      assert exercise_id == exercise.id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/exercise_executions", exercise_execution: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update exercise_execution" do
    setup do
      %{exercise_execution: insert(:exercise_execution)}
    end

    test "renders exercise_execution when data is valid", %{
      conn: conn,
      exercise_execution: %ExerciseExecution{id: id} = exercise_execution
    } do
      new_exercise = insert(:exercise)
      update_attrs = Map.put(@update_attrs, :exercise_id, new_exercise.id)

      conn =
        put(conn, ~p"/api/exercise_executions/#{exercise_execution}",
          exercise_execution: update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/exercise_executions/#{id}")

      assert %{
               "id" => ^id,
               "exercise" => %{"id" => exercise_id},
               "exercise_order" => 43,
               "note" => "some updated note"
             } = json_response(conn, 200)["data"]

      assert exercise_id == new_exercise.id
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      exercise_execution: exercise_execution
    } do
      conn =
        put(conn, ~p"/api/exercise_executions/#{exercise_execution}",
          exercise_execution: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete exercise_execution" do
    setup do
      %{exercise_execution: insert(:exercise_execution)}
    end

    test "deletes chosen exercise_execution", %{
      conn: conn,
      exercise_execution: exercise_execution
    } do
      conn = delete(conn, ~p"/api/exercise_executions/#{exercise_execution}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/exercise_executions/#{exercise_execution}")
      end
    end
  end
end
