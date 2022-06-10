defmodule Lurra.Monitoring.ObserverSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observers_sensors" do
    field :observer_id, :id
    field :sensor_id, :id
    field :element_id, :id

    timestamps()
  end

  @doc false
  def changeset(observer_sensor, attrs) do
    observer_sensor
    |> cast(attrs, [:observer_id, :sensor_id, :element_id])
    |> validate_required([:observer_id, :sensor_id])
  end
end
