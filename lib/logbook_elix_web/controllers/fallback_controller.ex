defmodule LogbookElixWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use LogbookElixWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: LogbookElixWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: LogbookElixWeb.ErrorHTML, json: LogbookElixWeb.ErrorJSON)
    |> render(:"404")
  end

  # This clause handles authentication errors from the Google token verifier.
  def call(conn, {:error, error_message}) when is_binary(error_message) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: error_message})
  end

  def call(conn, {:error, msg}) when is_atom(msg) do
    conn
    |> put_status(:bad_request)
    |> put_view(LogbookElixWeb.ErrorJSON)
    |> render("error.json", %{error: to_string(msg)})
  end

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> put_view(LogbookElixWeb.ErrorJSON)
    |> render("error.json", %{error: "Resource not found"})
  end
end
