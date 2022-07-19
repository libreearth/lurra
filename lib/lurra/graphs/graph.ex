defmodule Lurra.Graphs.Graph do
  use Ecto.Schema
  import Ecto.Changeset

  schema "graphs" do
    field :device_id, :string
    field :max_value, :float
    field :min_value, :float
    field :sensor_type, :integer

    timestamps()
  end

  @doc false
  def changeset(graph, attrs) do
    graph
    |> cast(attrs, [:device_id, :sensor_type, :max_value, :min_value])
    |> validate_required([:device_id, :sensor_type, :max_value, :min_value])
    |> unique_constraint([:device_id, :sensor_type])
  end
end
