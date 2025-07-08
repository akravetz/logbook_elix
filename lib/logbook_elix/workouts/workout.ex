defmodule LogbookElix.Workouts.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workouts" do
    field :finished_at, :utc_datetime

    belongs_to :user, LogbookElix.Accounts.User
    has_many :exercise_executions, LogbookElix.Executions.ExerciseExecution

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:finished_at, :user_id])
    |> validate_required([:user_id])
  end
end
