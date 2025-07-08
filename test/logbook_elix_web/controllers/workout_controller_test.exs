defmodule LogbookElixWeb.WorkoutControllerTest do
  use LogbookElixWeb.ConnCase

  import LogbookElix.Factory

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
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all workouts", %{conn: conn} do
      conn = get(conn, ~p"/api/workouts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create workout" do
    test "renders workout when data is valid", %{conn: conn} do
      user = insert(:user)
      attrs = Map.put(@create_attrs, :user_id, user.id)
      conn = post(conn, ~p"/api/workouts", workout: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/workouts/#{id}")

      assert %{
               "id" => ^id,
               "finished_at" => "2025-07-06T05:50:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/workouts", workout: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update workout" do
    setup [:create_workout]

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
  end

  describe "delete workout" do
    setup [:create_workout]

    test "deletes chosen workout", %{conn: conn, workout: workout} do
      conn = delete(conn, ~p"/api/workouts/#{workout}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/workouts/#{workout}")
      end
    end
  end

  defp create_workout(_) do
    workout = insert(:workout)
    %{workout: workout}
  end
end
