defmodule Lurra.Monitoring.Observer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observers" do
    field :device_id, :string
    field :name, :string
    many_to_many :sensors, Lurra.Monitoring.Sensor, join_through: Lurra.Monitoring.ObserverSensor, on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(observer, attrs) do
    observer
    |> cast(attrs, [:name, :device_id])
    |> validate_required([:name, :device_id])
  end
end
