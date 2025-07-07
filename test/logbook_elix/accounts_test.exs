defmodule LogbookElix.AccountsTest do
  use LogbookElix.DataCase

  alias LogbookElix.Accounts

  describe "users" do
    alias LogbookElix.Accounts.User

    import LogbookElix.AccountsFixtures

    @invalid_attrs %{name: nil, email_address: nil, google_id: nil, profile_image_url: nil, is_active: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", email_address: "some email_address", google_id: "some google_id", profile_image_url: "some profile_image_url", is_active: true}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.email_address == "some email_address"
      assert user.google_id == "some google_id"
      assert user.profile_image_url == "some profile_image_url"
      assert user.is_active == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", email_address: "some updated email_address", google_id: "some updated google_id", profile_image_url: "some updated profile_image_url", is_active: false}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.email_address == "some updated email_address"
      assert user.google_id == "some updated google_id"
      assert user.profile_image_url == "some updated profile_image_url"
      assert user.is_active == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
