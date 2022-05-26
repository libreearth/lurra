defmodule Lurra.Events.ReadingsCache do
  use GenServer

  alias Lurra.Events
  alias LurraWeb.Endpoint

  @events_topic "events"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{} = map) do
    Endpoint.subscribe(@events_topic)

    readings = Events.get_last_events()
      |> Enum.map(fn reading -> {{reading.device_id, parse_int(reading.type)}, reading |> payload() |> parse_float()} end)
      |> Enum.into(map)

    {:ok, readings}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, device_id: device_id, type: type}, topic: "events"}, state) do
    {
      :noreply,
      Map.put(state, {device_id, type}, payload)
    }
  end

  def handle_call(:get_readings, _from, state) do
    {:reply, state, state}
  end

  def get_readings() do
    GenServer.call(__MODULE__, :get_readings)
  end

  defp payload(nil), do: nil
  defp payload(event), do: event.payload

  defp parse_float(nil) do
    nil
  end

  defp parse_float(text) do
    {n, _} = Float.parse(text)
    n
  end

  defp parse_int(nil) do
    nil
  end

  defp parse_int(text) do
    {n, _} = Integer.parse(text)
    n
  end
end
