defmodule LogbookElix.Executions.ExerciseExecution do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exercise_executions" do
    field :exercise, :integer
    field :note, :string
    field :exercise_order, :integer
    
    belongs_to :workout, LogbookElix.Workouts.Workout
    has_many :sets, LogbookElix.Sets.Set

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise_execution, attrs) do
    exercise_execution
    |> cast(attrs, [:exercise, :note, :exercise_order, :workout_id])
    |> validate_required([:exercise, :exercise_order, :workout_id])
  end
end
