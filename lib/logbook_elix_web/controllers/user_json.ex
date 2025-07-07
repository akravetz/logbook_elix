defmodule LogbookElixWeb.UserJSON do
  alias LogbookElix.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email_address: user.email_address,
      google_id: user.google_id,
      name: user.name,
      profile_image_url: user.profile_image_url,
      is_active: user.is_active
    }
  end
end
