defmodule LogbookElix.Repo.Migrations.AddUniqueIndexToUsersEmailAddress do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email_address])
  end
end
