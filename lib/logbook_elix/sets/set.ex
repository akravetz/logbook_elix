defmodule LogbookElix.Sets.Set do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sets" do
    field :weight, :float
    field :clean_reps, :integer
    field :forced_reps, :integer, default: 0
    
    belongs_to :exercise_execution, LogbookElix.Executions.ExerciseExecution

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:weight, :clean_reps, :forced_reps, :exercise_execution_id])
    |> validate_required([:weight, :clean_reps, :exercise_execution_id])
  end
end
