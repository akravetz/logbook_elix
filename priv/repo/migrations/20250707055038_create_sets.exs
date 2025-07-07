defmodule LogbookElix.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :weight, :float
      add :clean_reps, :integer
      add :forced_reps, :integer
      add :exercise_execution_id, references(:exercise_executions, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:sets, [:exercise_execution_id])
  end
end
