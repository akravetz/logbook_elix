defmodule LogbookElixWeb.AuthControllerTest do
  use LogbookElixWeb.ConnCase

  import LogbookElix.Factory
  import LogbookElixWeb.AuthTestHelper

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "verify_google_token" do
    test "returns error for invalid Google token", %{conn: conn} do
      conn =
        post(conn, ~p"/api/auth/verify-google-token", %{
          "google_token" => "invalid-token"
        })

      assert response(conn, 401)
    end
  end

  describe "logout" do
    test "successfully logs out authenticated user", %{conn: conn} do
      user = insert(:user)
      authenticated_conn = authenticated_conn(conn, user)

      conn = post(authenticated_conn, ~p"/api/auth/logout")

      assert %{"message" => "Successfully logged out"} = json_response(conn, 200)
    end

    test "returns error for unauthenticated request", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/logout")

      assert response(conn, 401)
    end
  end

  describe "dev_login" do
    test "creates new dev user and returns JWT", %{conn: conn} do
      conn = post(conn, ~p"/api/dev/auth", %{"name" => "testuser"})

      assert %{
               "jwt" => jwt,
               "user" => %{
                 "id" => id,
                 "email" => "testuser@dev.com",
                 "name" => "testuser",
                 "profile_image_url" => "http://www.dev.com/testuser.png"
               }
             } = json_response(conn, 200)

      assert is_binary(jwt)
      assert is_integer(id)
    end

    test "returns existing dev user and new JWT for same name", %{conn: conn} do
      # First request
      conn1 = post(conn, ~p"/api/dev/auth", %{"name" => "testuser"})
      response1 = json_response(conn1, 200)

      # Second request with same name
      conn2 = post(conn, ~p"/api/dev/auth", %{"name" => "testuser"})
      response2 = json_response(conn2, 200)

      assert response1["user"]["id"] == response2["user"]["id"]
      assert response1["user"]["email"] == response2["user"]["email"]
      assert response1["jwt"] != response2["jwt"]
    end

    test "returns error for missing name parameter", %{conn: conn} do
      conn = post(conn, ~p"/api/dev/auth", %{})

      assert response(conn, 422)
    end

    test "creates user with correct dev attributes", %{conn: conn} do
      conn = post(conn, ~p"/api/dev/auth", %{"name" => "myuser"})

      assert %{
               "user" => %{
                 "email" => "myuser@dev.com",
                 "name" => "myuser",
                 "profile_image_url" => "http://www.dev.com/myuser.png"
               }
             } = json_response(conn, 200)
    end
  end
end
