defmodule Lurra.Monitoring.Observer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observers" do
    field :device_id, :string
    field :name, :string
    field :type, :string
    field :api_key, :string
    field :max_depth_level, :float
    field :min_depth_level, :float
    field :fan_level, :float
    field :timezone, :string
    field :archived, :boolean, default: false
    many_to_many :sensors, Lurra.Monitoring.Sensor, join_through: Lurra.Monitoring.ObserverSensor, on_replace: :delete
    timestamps()
  end

  @doc false
  def changeset(observer, attrs) do
    observer
    |> cast(attrs, [:name, :device_id, :type, :api_key, :max_depth_level, :min_depth_level, :fan_level, :timezone, :archived])
    |> validate_required([:name, :device_id])
  end
end
