defmodule LogbookElix.AccountsTest do
  use LogbookElix.DataCase

  import LogbookElix.Factory

  alias LogbookElix.Accounts

  describe "users" do
    alias LogbookElix.Accounts.User

    @invalid_attrs %{
      name: nil,
      email_address: nil,
      google_id: nil,
      profile_image_url: nil,
      is_active: nil
    }

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = params_for(:user)

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == valid_attrs.name
      assert user.email_address == valid_attrs.email_address
      assert user.google_id == valid_attrs.google_id
      assert user.profile_image_url == valid_attrs.profile_image_url
      assert user.is_active == valid_attrs.is_active
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "create_dev_user/1" do
    alias LogbookElix.Accounts.User

    test "creates a new dev user with correct attributes" do
      assert {:ok, %User{} = user} = Accounts.create_dev_user("testuser")
      assert user.name == "testuser"
      assert user.email_address == "testuser@dev.com"
      assert user.google_id == "dev-testuser"
      assert user.profile_image_url == "http://www.dev.com/testuser.png"
      assert user.is_active == true
    end

    test "updates existing dev user on conflict" do
      # Create first user
      {:ok, user1} = Accounts.create_dev_user("testuser")

      # Create again with same name (should update existing)
      {:ok, user2} = Accounts.create_dev_user("testuser")

      assert user1.id == user2.id
      assert user2.email_address == "testuser@dev.com"
      assert user2.google_id == "dev-testuser"
    end

    test "creates different users for different names" do
      {:ok, user1} = Accounts.create_dev_user("user1")
      {:ok, user2} = Accounts.create_dev_user("user2")

      assert user1.id != user2.id
      assert user1.email_address == "user1@dev.com"
      assert user2.email_address == "user2@dev.com"
      assert user1.google_id == "dev-user1"
      assert user2.google_id == "dev-user2"
    end
  end
end
