defmodule LogbookElixWeb.AuthController do
  use LogbookElixWeb, :controller

  alias LogbookElix.Accounts
  alias LogbookElix.Auth.GoogleTokenVerifier
  alias LogbookElix.Auth.Guardian

  action_fallback LogbookElixWeb.FallbackController

  @logout_success_message "Successfully logged out"

  def verify_google_token(conn, %{"google_token" => google_token}) do
    with {:ok, user_info} <- GoogleTokenVerifier.verify_token(google_token),
         {:ok, user} <- Accounts.find_or_create_user_by_email(user_info),
         {:ok, jwt, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> json(%{
        jwt: jwt,
        user: %{
          id: user.id,
          email: user.email_address,
          name: user.name,
          profile_image_url: user.profile_image_url
        }
      })
    end
  end

  def logout(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)

    with {:ok, _claims} <- Guardian.revoke(jwt) do
      conn
      |> put_status(:ok)
      |> json(%{message: @logout_success_message})
    end
  end

  @doc """
  Development-only authentication endpoint.

  Creates or updates a development user and returns a JWT token.
  Only available in development environment.
  """
  def dev_login(conn, %{"name" => name}) do
    with {:ok, user} <- Accounts.create_dev_user(name),
         {:ok, jwt, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> json(%{
        jwt: jwt,
        user: %{
          id: user.id,
          email: user.email_address,
          name: user.name,
          profile_image_url: user.profile_image_url
        }
      })
    end
  end

  def dev_login(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: %{name: ["is required"]}})
  end
end
