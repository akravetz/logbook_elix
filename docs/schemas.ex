defmodule WorkoutApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email_address, :string
    field :google_id, :string
    field :name, :string
    field :profile_image_url, :string
    field :is_active, :boolean, default: true
    field :is_admin, :boolean, default: false

    has_many :created_exercises, WorkoutApi.Exercises.Exercise, foreign_key: :created_by_user_id
    has_many :updated_exercises, WorkoutApi.Exercises.Exercise, foreign_key: :updated_by_user_id
    has_many :created_workouts, WorkoutApi.Workouts.Workout, foreign_key: :created_by_user_id
    has_many :updated_workouts, WorkoutApi.Workouts.Workout, foreign_key: :updated_by_user_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email_address, :google_id, :name, :profile_image_url, :is_active, :is_admin])
    |> validate_required([:email_address, :google_id, :name, :is_active, :is_admin])
    |> validate_format(:email_address, ~r/@/)
    |> unique_constraint(:email_address)
    |> unique_constraint(:google_id)
  end
end

defmodule WorkoutApi.Exercises.Exercise do
  use Ecto.Schema
  import Ecto.Changeset

  @exercise_modalities [:dumbbell, :barbell, :cable, :machine, :smith, :bodyweight]

  schema "exercises" do
    field :name, :string
    field :body_part, :string
    field :modality, Ecto.Enum, values: @exercise_modalities
    field :picture_url, :string
    field :is_user_created, :boolean, default: true

    belongs_to :created_by_user, WorkoutApi.Users.User, foreign_key: :created_by_user_id
    belongs_to :updated_by_user, WorkoutApi.Users.User, foreign_key: :updated_by_user_id
    has_many :exercise_executions, WorkoutApi.Workouts.ExerciseExecution
    has_many :sets, WorkoutApi.Workouts.Set

    timestamps()
  end

  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:name, :body_part, :modality, :picture_url, :is_user_created, :created_by_user_id, :updated_by_user_id])
    |> validate_required([:name, :body_part, :modality, :is_user_created])
    |> validate_inclusion(:modality, @exercise_modalities)
    |> foreign_key_constraint(:created_by_user_id)
    |> foreign_key_constraint(:updated_by_user_id)
  end
end

defmodule WorkoutApi.Workouts.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workouts" do
    field :finished_at, :utc_datetime

    belongs_to :created_by_user, WorkoutApi.Users.User, foreign_key: :created_by_user_id
    belongs_to :updated_by_user, WorkoutApi.Users.User, foreign_key: :updated_by_user_id
    has_many :exercise_executions, WorkoutApi.Workouts.ExerciseExecution, preload_order: [asc: :exercise_order]
    has_many :sets, WorkoutApi.Workouts.Set

    timestamps()
  end

  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:finished_at, :created_by_user_id, :updated_by_user_id])
    |> validate_required([:created_by_user_id, :updated_by_user_id])
    |> foreign_key_constraint(:created_by_user_id)
    |> foreign_key_constraint(:updated_by_user_id)
  end
end

defmodule WorkoutApi.Workouts.ExerciseExecution do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exercise_executions" do
    field :exercise_order, :integer
    field :note_text, :string

    belongs_to :workout, WorkoutApi.Workouts.Workout
    belongs_to :exercise, WorkoutApi.Exercises.Exercise
    has_many :sets, WorkoutApi.Workouts.Set, preload_order: [asc: :id]

    timestamps()
  end

  def changeset(exercise_execution, attrs) do
    exercise_execution
    |> cast(attrs, [:exercise_order, :note_text, :workout_id, :exercise_id])
    |> validate_required([:exercise_order, :workout_id, :exercise_id])
    |> foreign_key_constraint(:workout_id)
    |> foreign_key_constraint(:exercise_id)
    |> unique_constraint([:workout_id, :exercise_id], name: :uq_workout_exercise)
  end
end

defmodule WorkoutApi.Workouts.Set do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sets" do
    field :note_text, :string
    field :weight, :float
    field :clean_reps, :integer
    field :forced_reps, :integer, default: 0

    belongs_to :workout, WorkoutApi.Workouts.Workout
    belongs_to :exercise, WorkoutApi.Exercises.Exercise
    belongs_to :exercise_execution, WorkoutApi.Workouts.ExerciseExecution,
               foreign_key: :exercise_execution_id,
               references: :id,
               define_field: false

    timestamps()
  end

  def changeset(set, attrs) do
    set
    |> cast(attrs, [:note_text, :weight, :clean_reps, :forced_reps, :workout_id, :exercise_id])
    |> validate_required([:weight, :clean_reps, :workout_id, :exercise_id])
    |> validate_number(:weight, greater_than: 0)
    |> validate_number(:clean_reps, greater_than_or_equal_to: 0)
    |> validate_number(:forced_reps, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:workout_id)
    |> foreign_key_constraint(:exercise_id)
  end
end
