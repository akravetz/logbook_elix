defmodule LogbookElix.Exercises.Exercise do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :created_by_user]}
  schema "exercises" do
    field :name, :string

    field :body_part, Ecto.Enum,
      values: [
        :chest,
        :back,
        :legs,
        :arms,
        :core,
        :shoulders,
        :quads,
        :glutes,
        :hamstrings,
        :biceps,
        :triceps,
        :traps,
        :full_body
      ]

    field :modality, Ecto.Enum,
      values: [:barbell, :dumbbell, :cable, :machine, :bodyweight, :smith, :other]

    field :is_system_created, :boolean, default: false

    belongs_to :created_by_user, LogbookElix.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:name, :body_part, :modality, :is_system_created, :created_by_user_id])
    |> validate_required([:name, :body_part, :modality])
    |> validate_length(:name, min: 4, max: 255)
  end
end
