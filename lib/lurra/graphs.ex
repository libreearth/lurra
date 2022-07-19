defmodule Lurra.Graphs do
  import Ecto.Query, warn: false
  alias Lurra.Repo

  alias Lurra.Graphs.Graph

  def list(), do: Repo.all(Graph)

  def get_graph!(id), do: Repo.get!(Graph, id)

  def get_graph(device_id, sensor_type) do
    Repo.one(from g in Graph, where: g.device_id == ^device_id and g.sensor_type == ^sensor_type)
  end

  def save_graph(device_id, sensor_type, max, min) do
    case get_graph(device_id, sensor_type) do
      nil ->
        %Graph{device_id: device_id, sensor_type: sensor_type, max_value: max, min_value: min}
        |> Repo.insert!()
      graph ->
        graph
        |> Graph.changeset(%{max_value: max, min_value: min})
        |> Repo.update!()
    end
  end
end
