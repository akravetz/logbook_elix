defmodule LogbookElixWeb.ExerciseControllerTest do
  use LogbookElixWeb.ConnCase

  import LogbookElix.Factory
  import LogbookElixWeb.AuthTestHelper

  @create_attrs %{
    name: "Test Exercise",
    body_part: :chest,
    modality: :barbell
  }
  @update_attrs %{
    name: "Updated Exercise",
    body_part: :back,
    modality: :dumbbell
  }
  @invalid_attrs %{name: nil, body_part: nil, modality: nil}

  setup %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> authenticated_conn(user)

    {:ok, conn: conn, user: user}
  end

  describe "index" do
    test "lists user exercises and system exercises", %{conn: conn, user: user} do
      system_exercise = insert(:system_exercise)
      user_exercise = insert(:exercise, created_by_user: user)
      _other_user_exercise = insert(:exercise)

      conn = get(conn, ~p"/api/exercises")
      response_data = json_response(conn, 200)["data"]

      assert length(response_data) == 2
      exercise_ids = Enum.map(response_data, & &1["id"])
      assert system_exercise.id in exercise_ids
      assert user_exercise.id in exercise_ids
    end

    test "lists empty when no exercises exist", %{conn: conn} do
      conn = get(conn, ~p"/api/exercises")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create exercise" do
    test "renders exercise when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/exercises", exercise: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/exercises/#{id}")

      assert %{
               "id" => ^id,
               "body_part" => "chest",
               "is_system_created" => false,
               "modality" => "barbell",
               "name" => "Test Exercise"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/exercises", exercise: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show exercise" do
    test "renders user's exercise", %{conn: conn, user: user} do
      exercise = insert(:exercise, created_by_user: user)
      conn = get(conn, ~p"/api/exercises/#{exercise}")

      assert %{
               "id" => id,
               "name" => name
             } = json_response(conn, 200)["data"]

      assert id == exercise.id
      assert name == exercise.name
    end

    test "renders system exercise", %{conn: conn} do
      system_exercise = insert(:system_exercise)
      conn = get(conn, ~p"/api/exercises/#{system_exercise}")

      assert %{
               "id" => id,
               "is_system_created" => true
             } = json_response(conn, 200)["data"]

      assert id == system_exercise.id
    end

    test "returns error for other user's exercise", %{conn: conn} do
      other_exercise = insert(:exercise)
      conn = get(conn, ~p"/api/exercises/#{other_exercise}")
      assert json_response(conn, 401)["error"] != nil
    end
  end

  describe "update exercise" do
    test "renders exercise when data is valid", %{conn: conn, user: user} do
      exercise = insert(:exercise, created_by_user: user)
      conn = put(conn, ~p"/api/exercises/#{exercise}", exercise: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/exercises/#{id}")

      assert %{
               "id" => ^id,
               "body_part" => "back",
               "modality" => "dumbbell",
               "name" => "Updated Exercise"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      exercise = insert(:exercise, created_by_user: user)
      conn = put(conn, ~p"/api/exercises/#{exercise}", exercise: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "prevents updating system exercise", %{conn: conn} do
      system_exercise = insert(:system_exercise)
      conn = put(conn, ~p"/api/exercises/#{system_exercise}", exercise: @update_attrs)
      assert json_response(conn, 401)["error"] != nil
    end

    test "prevents updating other user's exercise", %{conn: conn} do
      other_exercise = insert(:exercise)
      conn = put(conn, ~p"/api/exercises/#{other_exercise}", exercise: @update_attrs)
      assert json_response(conn, 401)["error"] != nil
    end
  end

  describe "delete exercise" do
    test "deletes chosen exercise", %{conn: conn, user: user} do
      exercise = insert(:exercise, created_by_user: user)
      conn = delete(conn, ~p"/api/exercises/#{exercise}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/exercises/#{exercise}")
      assert json_response(conn, 401)["error"] != nil
    end

    test "prevents deleting system exercise", %{conn: conn} do
      system_exercise = insert(:system_exercise)
      conn = delete(conn, ~p"/api/exercises/#{system_exercise}")
      assert json_response(conn, 401)["error"] != nil
    end

    test "prevents deleting other user's exercise", %{conn: conn} do
      other_exercise = insert(:exercise)
      conn = delete(conn, ~p"/api/exercises/#{other_exercise}")
      assert json_response(conn, 401)["error"] != nil
    end
  end
end
