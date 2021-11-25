defmodule Lurra.Monitoring.ObserverSensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observers_sensors" do
    field :observer_id, :id
    field :sensor_id, :id

    timestamps()
  end

  @doc false
  def changeset(observer_sensor, attrs) do
    observer_sensor
    |> cast(attrs, [])
    |> validate_required([])
  end
end
