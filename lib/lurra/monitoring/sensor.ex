defmodule Lurra.Monitoring.Sensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sensors" do
    field :name, :string
    field :sensor_type, :integer
    field :unit, :string
    field :value_type, :string

    timestamps()
  end

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, [:value_type, :name, :sensor_type, :unit])
    |> validate_required([:value_type, :name, :sensor_type, :unit])
  end
end
