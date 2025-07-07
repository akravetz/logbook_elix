defmodule LogbookElix.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email_address, :string
    field :google_id, :string
    field :profile_image_url, :string
    field :is_active, :boolean, default: true

    has_many :workouts, LogbookElix.Workouts.Workout

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email_address, :google_id, :name, :profile_image_url, :is_active])
    |> validate_required([:email_address, :google_id, :name, :profile_image_url, :is_active])
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
