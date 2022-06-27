defmodule Lurra.Monitoring.ObserverSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observers_sensors" do
    field :observer_id, :id
    field :sensor_id, :id
    field :element_id, :id
    field :location_type, :string

    timestamps()
  end

  @doc false
  def changeset(observer_sensor, attrs) do
    observer_sensor
    |> cast(attrs, [:observer_id, :sensor_id, :element_id, :location_type])
    |> validate_required([:observer_id, :sensor_id])
  end
end
