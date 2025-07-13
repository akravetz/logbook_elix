defmodule LogbookElixWeb.WorkoutControllerTest do
  use LogbookElixWeb.ConnCase

  import LogbookElix.Factory
  import LogbookElixWeb.AuthTestHelper

  alias LogbookElix.Workouts.Workout

  # Will be merged with user_id in tests
  @create_attrs %{
    finished_at: ~U[2025-07-06 05:50:00Z]
  }
  @update_attrs %{
    finished_at: ~U[2025-07-07 05:50:00Z]
  }
  @invalid_attrs %{user_id: nil}

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> authenticated_conn()

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all workouts", %{conn: conn} do
      conn = get(conn, ~p"/api/workouts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workout" do
    test "renders workout when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/workouts", workout: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/workouts/#{id}")

      assert %{
               "id" => ^id,
               "finished_at" => "2025-07-06T05:50:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = %{finished_at: "invalid-date"}
      conn = post(conn, ~p"/api/workouts", workout: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workout" do
    setup %{conn: conn} do
      # Create workout for the authenticated user
      user = extract_user_from_conn(conn)
      %{workout: insert(:workout, user: user)}
    end

    test "renders workout when data is valid", %{conn: conn, workout: %Workout{id: id} = workout} do
      conn = put(conn, ~p"/api/workouts/#{workout}", workout: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/workouts/#{id}")

      assert %{
               "id" => ^id,
               "finished_at" => "2025-07-07T05:50:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, workout: workout} do
      conn = put(conn, ~p"/api/workouts/#{workout}", workout: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns unauthorized when trying to update another user's workout", %{conn: conn} do
      other_user = insert(:user)
      other_workout = insert(:workout, user: other_user)

      conn = put(conn, ~p"/api/workouts/#{other_workout}", workout: @update_attrs)
      assert json_response(conn, 401)["error"] == "Workout not found or access denied"
    end
  end

  describe "delete workout" do
    setup %{conn: conn} do
      # Create workout for the authenticated user
      user = extract_user_from_conn(conn)
      %{workout: insert(:workout, user: user)}
    end

    test "deletes chosen workout", %{conn: conn, workout: workout} do
      conn = delete(conn, ~p"/api/workouts/#{workout}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/workouts/#{workout}")
      assert json_response(conn, 401)["error"] == "Workout not found or access denied"
    end

    test "returns unauthorized when trying to delete another user's workout", %{conn: conn} do
      other_user = insert(:user)
      other_workout = insert(:workout, user: other_user)

      conn = delete(conn, ~p"/api/workouts/#{other_workout}")
      assert json_response(conn, 401)["error"] == "Workout not found or access denied"
    end
  end

  describe "show workout" do
    test "returns unauthorized when trying to view another user's workout", %{conn: conn} do
      other_user = insert(:user)
      other_workout = insert(:workout, user: other_user)

      conn = get(conn, ~p"/api/workouts/#{other_workout}")
      assert json_response(conn, 401)["error"] == "Workout not found or access denied"
    end
  end
end
