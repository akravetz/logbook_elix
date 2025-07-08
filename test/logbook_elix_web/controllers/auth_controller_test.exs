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
end
