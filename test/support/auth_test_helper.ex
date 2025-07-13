defmodule LogbookElixWeb.AuthTestHelper do
  @moduledoc """
  Helper functions for testing authenticated endpoints.
  """

  import LogbookElix.Factory
  alias LogbookElix.Auth.Guardian

  @doc """
  Creates an authenticated connection with a JWT token for testing.
  """
  def authenticated_conn(conn) do
    user = insert(:user)
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

    conn
    |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt}")
  end

  @doc """
  Creates an authenticated connection with a specific user.
  """
  def authenticated_conn(conn, user) do
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

    conn
    |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt}")
  end

  @doc """
  Extracts the authenticated user from the connection.
  This function assumes the connection was created with authenticated_conn/1.
  """
  def extract_user_from_conn(conn) do
    # Extract the JWT token from the authorization header
    auth_header = List.first(Plug.Conn.get_req_header(conn, "authorization"))
    "Bearer " <> jwt = auth_header

    # Decode the JWT to get the user
    {:ok, claims} = Guardian.decode_and_verify(jwt)
    {:ok, user} = Guardian.resource_from_claims(claims)
    user
  end
end
