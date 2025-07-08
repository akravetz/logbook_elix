defmodule LogbookElixWeb.UserControllerTest do
  use LogbookElixWeb.ConnCase

  import LogbookElix.Factory

  alias LogbookElix.Accounts.User

  # Only name is updatable per CLAUDE.md guidelines
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "show user" do
    setup do
      %{user: insert(:user)}
    end

    test "renders user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users/#{user}")
      assert %{
               "id" => id,
               "email_address" => _email,
               "google_id" => _google_id,
               "is_active" => _is_active,
               "name" => _name,
               "profile_image_url" => _profile_url
             } = json_response(conn, 200)["data"]
      assert id == user.id
    end
  end

  describe "update user" do
    setup do
      %{user: insert(:user)}
    end

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
