defmodule LogbookElix.Repo.Migrations.UpdateExerciseExecutionsAddExerciseReference do
  use Ecto.Migration

  def change do
    alter table(:exercise_executions) do
      add :exercise_id, references(:exercises, on_delete: :restrict), null: false
      remove :exercise
    end

    create index(:exercise_executions, [:exercise_id])
  end
end
