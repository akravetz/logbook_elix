defmodule LogbookElix.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email_address, :string
      add :google_id, :string
      add :name, :string
      add :profile_image_url, :string
      add :is_active, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
