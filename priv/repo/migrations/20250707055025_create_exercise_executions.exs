defmodule LogbookElix.Repo.Migrations.CreateExerciseExecutions do
  use Ecto.Migration

  def change do
    create table(:exercise_executions) do
      add :exercise, :integer
      add :note, :string
      add :exercise_order, :integer
      add :workout_id, references(:workouts, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:exercise_executions, [:workout_id])
  end
end
