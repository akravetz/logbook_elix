defmodule LogbookElix.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LogbookElix.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email_address: "some email_address",
        google_id: "some google_id",
        is_active: true,
        name: "some name",
        profile_image_url: "some profile_image_url"
      })
      |> LogbookElix.Accounts.create_user()

    user
  end
end
