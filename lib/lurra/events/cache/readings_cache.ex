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

    timestamps = Events.get_last_events()
      |> Enum.map(fn reading -> {{reading.device_id, parse_int(reading.type)}, reading |> timestamp()} end)
      |> Enum.into(map)

    {:ok, {readings, timestamps}}
  end

  def handle_info(%{event: "event_created", payload: %{ payload: payload, device_id: device_id, type: type}, topic: "events"}, {readings, timestamps}) do
    {
      :noreply,
      {Map.put(readings, {device_id, type}, payload), Map.put(timestamps, {device_id, type}, :os.system_time(:millisecond))}
    }
  end

  def handle_call(:get_readings, _from, {readings, _timestamps} = state) do
    {:reply, readings, state}
  end

  def handle_call(:get_timestamps, _from, {_readings, timestamps} = state) do
    {:reply, timestamps, state}
  end

  def get_readings() do
    GenServer.call(__MODULE__, :get_readings)
  end

  def get_timestamps() do
    GenServer.call(__MODULE__, :get_timestamps)
  end

  defp payload(nil), do: nil
  defp payload(event), do: event.payload

  defp timestamp(nil), do: nil
  defp timestamp(event), do: event.timestamp

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
