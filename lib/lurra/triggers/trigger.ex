defmodule Lurra.Triggers.Trigger do
  use Ecto.Schema
  import Ecto.Changeset

  schema "triggers" do
    field :actions, :string
    field :device_id, :string
    field :name, :string
    field :rule, :string
    field :sensor_type, :integer

    timestamps()
  end

  @doc false
  def changeset(trigger, attrs) do
    trigger
    |> cast(attrs, [:name, :device_id, :sensor_type, :rule, :actions])
    |> validate_required([:name, :device_id, :sensor_type, :rule, :actions])
  end
end
