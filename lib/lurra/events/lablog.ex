defmodule Lurra.Events.Lablog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lablogs" do
    field :payload, :string
    field :timestamp, :integer
    field :user, :string

    timestamps()
  end

  @doc false
  def changeset(lablog, attrs) do
    lablog
    |> cast(attrs, [:payload, :user, :timestamp])
    |> validate_required([:payload, :user, :timestamp])
  end
end
