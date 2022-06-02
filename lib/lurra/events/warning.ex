defmodule Lurra.Events.Warning do
  use Ecto.Schema
  import Ecto.Changeset

  schema "warnings" do
    field :date, :integer
    field :description, :string
    field :device_id, :string
    field :sensor_type, :integer

    timestamps()
  end

  @doc false
  def changeset(warning, attrs) do
    warning
    |> cast(attrs, [:date, :device_id, :sensor_type, :description])
    |> validate_required([:date, :device_id, :sensor_type, :description])
  end
end
