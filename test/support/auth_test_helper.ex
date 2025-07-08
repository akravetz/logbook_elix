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

end