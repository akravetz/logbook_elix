defmodule LogbookElix.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises) do
      add :name, :text, null: false
      add :body_part, :text, null: false
      add :modality, :text, null: false
      add :is_system_created, :boolean, default: false, null: false
      add :created_by_user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:exercises, [:created_by_user_id])
    create index(:exercises, [:is_system_created])
    create index(:exercises, [:name])
  end
end
